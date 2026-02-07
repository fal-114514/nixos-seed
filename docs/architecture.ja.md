# NixOS Configuration Architecture (Infrastructure & Design)

## 1. ディレクトリ構造とコンポーネント定義

### 1.1 階層構造

```mermaid
graph TD
    Root["/"] --> Flake["flake.nix (Entry Point)"]
    Root --> Hosts["hosts/ (Fleet Definitions)"]
    Root --> Modules["modules/ (Shared Logic)"]

    Hosts --> HostDir["{hostname}/"]
    HostDir --> Var["variables.nix (State Set)"]
    HostDir --> Config["configuration.nix (System Logic)"]
    HostDir --> Home["home.nix (User Logic)"]
    HostDir --> HwConfig["hardware-configuration.nix (Auto-generated)"]
    HostDir --> HostConfigDir["config/ (Static Assets)"]
    HostDir --> HostModules["modules/ (Host-local Logic)"]

    Modules --> DE["DE/ (Desktop Environments)"]
    Modules --> ModDefault["default.nix (Module Aggregator)"]
    Modules --> ModHome["home.nix (Home Module Aggregator)"]

    DE --> DE_Gnome["gnome/"]
    DE --> DE_Kde["kde/"]
    DE --> DE_Niri["niri/"]

    DE_Gnome --> Gnome_NixOS["nixos.nix (NixOS Config)"]
    DE_Gnome --> Gnome_HM["gnome.nix (HM Config)"]

    HostModules --> Modules
```

### 1.2 構成要素の責務

| コンポーネント      | 役割                                                | 入力                              | 出力                     |
| :------------------ | :-------------------------------------------------- | :-------------------------------- | :----------------------- |
| `flake.nix`         | 全体の統合、依存関係の解決、ホストのインスタンス化  | `inputs`, `hosts/*/variables.nix` | `nixosConfigurations`    |
| `variables.nix`     | ホスト固有のパラメーター定義（純粋なAttribute Set） | なし                              | `var`オブジェクト        |
| `configuration.nix` | システム権限設定（Boot, HW, Network, Users）        | `{ config, pkgs, var, ... }`      | NixOS システムオプション |
| `home.nix`          | ユーザー環境設定（Dotfiles, User Packages）         | `{ config, pkgs, var, ... }`      | Home Manager オプション  |

---

## 2. 実装メカニズムとデータフロー

### 2.1 抽象化レイヤー: `mkHost` ヘルパー

`flake.nix` 内で定義された `mkHost` 関数は、`nixosSystem` インスタンス化の定型処理をカプセル化します。

- **シグネチャ**: `mkHost = hostName: dir: ...`
- **パス解決**: `(dir + "/variables.nix")` のように、ディレクトリパスと文字列を結合してホスト固有のファイルを動的にインポート。
- **アーキテクチャ推論**: `variables.nix` 内の `system.architecture` を読み取り、`nixpkgs.lib.nixosSystem` の `system` 引数へ渡す。

### 2.2 依存注入 (DI) チェーンとスコープ伝播

```mermaid
sequenceDiagram
    participant F as flake.nix
    participant V as variables.nix
    participant N as NixOS Module (configuration.nix)
    participant H as Home Manager (home.nix)
    participant M as Shared Module (modules/)

    F->>V: import
    V-->>F: return var (Attribute Set)
    F->>N: lib.nixosSystem with inputs and var
    N->>M: imports (shared logic)
    N->>H: home-manager.extraSpecialArgs with inputs and var
    H->>M: imports (shared HM logic)
```

- **`specialArgs`**: すべてのモジュール引数に `inputs` (Flake inputs) と `var` (Custom variables) を追加。これにより、各モジュールで `import` を記述することなく、グローバルな状態にアクセス可能。
- **Scoped Variables**: Home Manager 統合において、`home-manager.users.${var.user.name}` のように、`var` に基づいた動的な属性パス定義を実施。

### 2.3 モジュール結合と条件付き評価 (NixOS / Home Manager 分離)

デスクトップ環境（DE）の設定は、システムレベル（NixOS）とユーザーレベル（Home Manager）で分離され、`modules/DE/` 配下で一元管理されます。

- **NixOS (`nixos.nix`)**: ディスプレイドライバー、サービス有効化、システムパッケージ。
- **Home Manager (`*.nix`)**: ユーザー固有のパッケージ、設定ファイルのリンク（dotfiles）、各 DE の内部設定。
- **動的な集約**: `modules/default.nix` (NixOS 側) および `modules/home.nix` (HM 側) がこれらをインポートし、`variables.nix` のフラグに基づいて自動的に評価されます。

---

## 4. 拡張ガイドライン

### 4.1 新規ホストの追加

1.  **ディレクトリ作成**: `hosts/template` を `hosts/{hostname}` にコピー。
2.  **変数の調整**: `hosts/{hostname}/variables.nix` を開き、`hostname`, `user.name`, `architecture` 等を設定。
3.  **ハードウェア定義**: インストール先で `nixos-generate-config` を実行し、`hardware-configuration.nix` を配置。
4.  **Flake 登録**: `flake.nix` の `outputs.nixosConfigurations` に `mkHost` 呼び出しを追加（ホスト名指定に注意）。

### 4.2 共有モジュールの追加

1.  **モジュール作成**: `modules/` 配下に機能単位のディレクトリまたはファイルを作成（例: `modules/services/docker.nix`）。
2.  **インターフェイス定義**: `lib.mkIf var.{service}.enable` を使用して条件付き評価を実装。
3.  **集約**: `modules/default.nix`（または `home.nix`）の `imports` に新しいモジュールパスを追加。これにより、全ホストからアクセス可能になる。

---

## 5. 内部データ構造と依存注入 (Deep Dive)

### 5.1 `variables.nix` の構造

`variables.nix` は、設定ロジックを含まない「純粋なデータセット」として構成します。

```nix
{
  user = { name = "fal"; ... };
  system = { architecture = "x86_64-linux"; ... };
  desktop = {
    enableGnome = true;
    gnomeConfigPath = ./config/DE/gnome/default.nix;
    ...
  };
}
```

### 5.2 `specialArgs` による DI

`flake.nix` で定義された `var` は、すべての NixOS モジュールの第一引数として自動的に渡されます。

```nix
# モジュール側での受け取り例
{ config, pkgs, var, ... }: {
  networking.hostName = var.system.hostname;
}
```

これにより、各ファイル内での `import "../../hosts/xxx/variables.nix"` といったパス解決を排除し、コードの結合度を下げつつグローバルな状態管理を実現しています。

---

## 6. Home Manager 統合と境界線

### 6.1 システム設定 vs ユーザー設定

本構成では、以下のルールに基づいて設定を分離します。

- **NixOS (configuration.nix / nixos.nix)**: ハードウェア、ドライバー、システムサービス（Docker, SSH）、ユーザー管理、フォント、デスクトップ環境の基本サービス有効化。
- **Home Manager (home.nix / DE-specific nix)**: アプリケーション設定（Dotfiles）、ユーザーパッケージ（Vivaldi, CLI ツール）、デスクトップ環境のテーマ設定や拡張機能。

### 6.2 パス解決の原則

Home Manager モジュールも `var` にアクセス可能であるため、`var.desktop.gnomeConfigPath` のように `variables.nix` で定義されたリソースパスを直接参照し、一意性を担保します。

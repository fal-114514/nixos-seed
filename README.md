# NixOS Starter Configuration

このディレクトリは、モジュール性とカスタマイズ性を重視したNixOSのスターター設定です。
`variables.nix` を編集するだけで、システムの主要な設定を変更できるように設計されています。

## 目次 / Table of Contents

- [NixOS Starter Configuration](#nixos-starter-configuration)
  - [目次 / Table of Contents](#目次--table-of-contents)
  - [Branch Guide / ブランチ構成](#branch-guide--ブランチ構成)
  - [ディレクトリ構造 / Directory Structure](#ディレクトリ構造--directory-structure)
  - [仕組み / Mechanism](#仕組み--mechanism)
  - [セットアップ手順 / Getting Started](#セットアップ手順--getting-started)
    - [1. リポジトリのダウンロード](#1-リポジトリのダウンロード)
    - [2. ハードウェア情報の生成](#2-ハードウェア情報の生成)
    - [3. 変数の設定](#3-変数の設定)
    - [4. 設定の適用](#4-設定の適用)
  - [主要なコマンド / Key Commands](#主要なコマンド--key-commands)
  - [カスタマイズ例 / Customization Examples](#カスタマイズ例--customization-examples)
    - [SSHポートの変更](#sshポートの変更)
    - [デスクトップ環境の切り替え](#デスクトップ環境の切り替え)
  - [開発について / About Development](#開発について--about-development)
  - [ライセンス / License](#ライセンス--license)

## Branch Guide / ブランチ構成

- [mainブランチ](../../tree/main): デフォルトブランチ
  - NixOSの設定に馴染みがない方向け
  - 安定版
  - フラットな構造
- [testブランチ](../../tree/test): テスト兼玄人向けブランチ
  - 新機能のテスト
  - 玄人向け
> [!CAUTION]
> testブランチは作者自身ですら完璧に理解できていません。
> 初めて設定を触るよー、って方にはmainブランチを推奨します。

## ディレクトリ構造 / Directory Structure

```plaintext
starter/
├── flake.nix                   # エントリーポイント / Entry Point
├── variables.nix               # ユーザー変数定義 / User Variables
├── configuration.nix           # システム全体の設定 / System Configuration
├── home.nix                    # ユーザー固有の設定 (Home Manager) / User Configuration
└── DE/                         # デスクトップ環境 (Desktop Environments)
    ├── gnome/                  # Gnome設定モジュール
    ├── niri/                   # Niri設定モジュール
    └── ...
```

## 仕組み / Mechanism

この設定は **Nix Flakes** をベースにしており、以下の流れで設定が適用されます。

1.  **`flake.nix`**:
    - 全設定の起点です。
    - `variables.nix` を最初に読み込み (`import ./variables.nix`)、その内容を `var` という変数に格納します。
    - `specialArgs` と `extraSpecialArgs` を使用して、この `var` を他のすべてのモジュール（`configuration.nix` や `home.nix` など）に渡します。
    - これにより、どのファイルからでも `var.user.name` や `var.desktop.enableGnome` といった形で変数を参照できます。

2.  **`variables.nix`**:
    - ユーザーが変更すべき設定値を一箇所にまとめています。
    - ユーザー名、ホスト名、デスクトップ環境の選択、SSHポート設定などが含まれます。
    - **カスタマイズ方法**: 基本的にこのファイルを編集するだけで、好みの環境に変更できます。

3.  **`configuration.nix`**:
    - OSレベルの設定（ネットワーク、SSH、ブートローダー、システムパッケージなど）を行います。
    - `variables.nix` の値を参照して、条件分岐 (`if` / `else`) や値の代入を動的に行います。
    - 例: `services.openssh.ports = [ var.network.sshPort ];`

4.  **`home.nix`** (Home Manager):
    - ユーザー権限でインストールするアプリやツールの設定（Git、ターミナル、エディターなど）を行います。
    - `DE/` ディレクトリ内のモジュールをインポートしており、`variables.nix` の設定に応じて特定のデスクトップ環境の設定を有効化します。

5.  **`DE/` (Desktop Environments)**:
    - デスクトップ環境ごとの設定が分離されています（例: `DE/niri/niri.nix`）。
    - 各モジュールは `mkIf` 関数を使用しており、`variables.nix` で `true` に設定された場合のみ有効になります。

## セットアップ手順 / Getting Started

新規インストールまたは既存システムへの適用手順です。

### 1. リポジトリのダウンロード

この設定ディレクトリをローカル環境に配置します。

```bash
git clone <repository_url> nixos-config
cd nixos-config/starter
```

### 2. ハードウェア情報の生成

インストール先のハードウェアに合わせた設定ファイル (`hardware-configuration.nix`) を生成します。
既存のシステムで既に存在する場合は、それをコピーして使用してください。

```bash
# 新規インストールの場合
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 3. 変数の設定

`variables.nix` を開き、自分の環境に合わせて各種変数を編集します。

- `user.name`: ユーザー名
- `system.hostname`: ホスト名
- `desktop.enableGnome`: デスクトップ環境の選択
- `network.sshPort`: SSHポート番号など

```nix
# variables.nix の例
user = {
  name = "your_username";
  # ...
};
```

### 4. 設定の適用

以下のコマンドを実行して設定をシステムに適用します。
`<Hostname>` は `variables.nix` で設定した `system.hostname` (デフォルトは `nixos-desktop`) と一致させる必要があります。

```bash
# 初回インストール時など、flake.lockがない場合は生成されます
sudo nixos-rebuild switch --flake .#nixos-desktop
```

## 主要なコマンド / Key Commands

- **設定の適用 (Switch)**:

  ```bash
  sudo nixos-rebuild switch --flake .#<hostname>
  ```

- **起動時テスト (Boot)**:
  現在の設定を変更せず、次回の起動時のみ新しい設定を使用します（安全なテスト用）。

  ```bash
  sudo nixos-rebuild boot --flake .#<hostname>
  ```

- **更新 (Update)**:
  `flake.lock` を更新してパッケージを最新にします。
  ```bash
  nix flake update
  sudo nixos-rebuild switch --flake .#<hostname>
  ```

## カスタマイズ例 / Customization Examples

### SSHポートの変更

`variables.nix` を編集します：

```nix
  network = {
    # ...
    sshPort = 2222; # 22から変更
  };
```

### デスクトップ環境の切り替え

`variables.nix` で `true` / `false` を切り替えます：

```nix
  desktop = {
    enableGnome = false;
    enableNiri = true;
    displayManager = "lemurs";
    # ...
  };
```

## 開発について / About Development

このリポジトリは、私が NixOS の学習と環境構築の効率化を目的にAIを使用し作成した「実験場」です。  
あくまで個人用設定の公開であるため、汎用的な動作保証はしていません。利用される際は、内容を理解した上で自己責任での使用をお願いします。

## ライセンス / License

このプロジェクトは **MIT License** の下で公開されています。

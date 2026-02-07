# NixOS セットアップガイド (日本語)

このガイドでは、このリポジトリのスターター構成を使用して NixOS をセットアップする手順を詳細に説明します。

## 1. 準備

このリポジトリをローカルに配置します。

```bash
git clone https://github.com/fal-114514/nixos-seed.git nixos-config
cd nixos-config
```

## 2. ディレクトリ構造の理解

現在の構造は「マルチホスト」対応になっています。

- `hosts/`: ホストごとの個別の設定（個人用、テンプレート用など）
- `modules/`: 共有される機能モジュール（デスクトップ環境など）
- `flake.nix`: 全体のエントリーポイント。ここでホスト名を定義します。

## 3. ホストの作成と設定

基本的には `hosts/template` をコピーして新しいホストを作成することを推奨します。

### ステップ A: ハードウェア情報の生成

インストール先のマシンで以下を実行します。

```bash
nixos-generate-config --show-hardware-config > hosts/<your-host-name>/hardware-configuration.nix
```

### ステップ B: 変数の設定

`hosts/<your-host-name>/variables.nix` を編集します。

- `user.name`: ユーザー名
- `system.hostname`: ホスト名（`flake.nix` での定義と合わせる必要があります）
- `desktop.enableGnome`, `enableNiri` など: デスクトップ環境の選択
- `inputMethod.type`, `fcitx5Layout`: 入力メソッドの種類と物理キーボードのレイアウト（例: `"fcitx5"`, `"us"`）

### ステップ C: ホスト固有の設定

- `hosts/<your-host-name>/configuration.nix`: システム全体の設定
- `hosts/<your-host-name>/home.nix`: ユーザー個別の設定
- `hosts/<your-host-name>/config/`: 各種アプリケーションの config ファイル

## 4. `flake.nix` への登録

`flake.nix` の `outputs` セクションに新しいホストを追加します。

```nix
nixosConfigurations = {
  "your-host-name" = mkHost "your-host-name" ./hosts/your-host-name;
};
```

## 5. 設定の適用

```bash
sudo nixos-rebuild switch --flake .#your-host-name
```

## トラブルシューティング

- **hardware-configuration.nix がない**: `hosts` ディレクトリ配下の各ホスト用フォルダに配置されていることを確認してください。
- **ホスト名が一致しない**: `variables.nix` の `system.hostname` と `flake.nix` の定義名、および `nixos-rebuild` の `#` 以降の名前を一致させる必要があります。

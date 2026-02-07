# NixOS セットアップガイド (フラット構成)

このガイドでは、このリポジトリのシンプルな構成を使用して NixOS をセットアップする手順を説明します。

## 1. 準備

このリポジトリをローカルに配置します。

```bash
git clone https://github.com/fal-114514/nixos-seed.git nixos-config
cd nixos-config
```

## 2. 設定の変更

主な設定箇所は `variables.nix` です。このファイルを編集して、自分の環境に合わせます。

### 変数の設定 (`variables.nix`)

- `user.name`: ユーザー名
- `system.hostname`: ホスト名
- `inputMethod.fcitx5Layout`: キーボードのレイアウト (例: `"us"`, `"jp"`)
- `desktop.enableGnome`, `enableNiri`: 使用するデスクトップ環境を `true` にします。

### ハードウェア情報の生成

インストール先のマシンで以下を実行し、設定を取り込みます。

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

## 3. 設定の適用

設定が完了したら、以下のコマンドでシステムをビルド・適用します。

```bash
sudo nixos-rebuild switch --flake .
```

## 重要なファイル

- `configuration.nix`: システム全体の基本的な設定（ブートローダー、ネットワーク、ユーザー等）。
- `home.nix`: ユーザー個別の設定（パッケージ、ドットファイル等）。
- `variables.nix`: ほとんどの個人設定をここで行えます。
- `DE/`: デスクトップ環境ごとの具体的な設定が含まれます。

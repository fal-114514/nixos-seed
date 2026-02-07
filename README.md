# NixOS Starter Configuration (Flat Structure)

このリポジトリは、シンプルさとカスタマイズ性を重視したNixOSのスターター設定です。
設定項目を `variables.nix` に集約しており、初心者でも簡単に自分好みの環境を構築できます。

## 目次 / Table of Contents

- [ディレクトリ構造](#ディレクトリ構造)
- [セットアップ手順](#セットアップ手順)
- [詳細ドキュメント](#詳細ドキュメント)
- [ブランチ構成](#ブランチ構成)

## ディレクトリ構造

```plaintext
.
├── flake.nix           # システムのエントリーポイント
├── variables.nix       # 設定変数（ユーザー名、ホスト名、入力メソッドなど）
├── configuration.nix   # システム全体の設定
├── home.nix            # ユーザー個別の設定 (Home Manager)
├── DE/                 # デスクトップ環境別の詳細設定 (Gnome, Niri等)
└── docs/               # マニュアル類
```

## セットアップ手順

1. `variables.nix` を編集してユーザー名やキーボードレイアウトを設定します。
2. `nixos-generate-config --show-hardware-config > hardware-configuration.nix` でハードウェア設定を生成します。
3. `sudo nixos-rebuild switch --flake .` を実行して適用します。

## 詳細ドキュメント

より詳しい使い方や構成の解説については、以下のマニュアルを参照してください。

- [**セットアップガイド (日本語)**](./docs/setup-guide.ja.md)
- [**構成解説 (日本語)**](./docs/architecture.ja.md)

## ブランチ構成

- **`main` ブランチ**: 現在のブランチ。初心者向けの「フラットな構造」を維持した安定版です。
- **`test` ブランチ**: 玄人向けの「マルチホスト構造」を採用した実験用ブランチです。

## ライセンス

このプロジェクトは **MIT License** の下で公開されています。

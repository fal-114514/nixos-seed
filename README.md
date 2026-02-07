# NixOS Starter Configuration

このリポジトリは、モジュール性とカスタマイズ性を重視したNixOSのスターター設定です。
マルチホスト（複数マシン）対応の構造になっており、各ホストごとの設定を独立して管理できます。

## 目次 / Table of Contents

- [NixOS Starter Configuration](#nixos-starter-configuration)
  - [目次 / Table of Contents](#目次--table-of-contents)
  - [ディレクトリ構造 / Directory Structure](#ディレクトリ構造--directory-structure)
  - [仕組み / Mechanism](#仕組み--mechanism)
  - [セットアップ手順 / Getting Started](#セットアップ手順--getting-started)
    - [クイックスタート (既設ホストの適用)](#クイックスタート-既設ホストの適用)
  - [主要なコマンド / Key Commands](#主要なコマンド--key-commands)
  - [ライセンス / License](#ライセンス--license)

## ディレクトリ構造 / Directory Structure

```plaintext
.
├── flake.nix               # エントリーポイント / Entry Point (ホスト定義)
├── hosts/                  # ホスト別の設定 / Host-specific configurations
│   ├── desktop/            # 個人用環境
│   │   ├── variables.nix   # ホスト別変数設定
│   │   ├── configuration.nix
│   │   ├── home.nix
│   │   ├── config/         # アプリ別の設定ファイル
│   │   │   └── DE/         # デスクトップ環境別設定 (Niri等)
│   │   └── modules/        # ホスト固有モジュール
│   │       └── default.nix
│   └── template/           # 新規ホスト作成用テンプレート
│       ├── variables.nix
│       ├── configuration.nix
│       ├── home.nix
│       ├── config/
│       │   └── DE/
│       └── modules/
│           └── default.nix
├── modules/                # 共有モジュール / Shared modules
│   ├── default.nix         # モジュール集約ファイル
│   ├── home.nix            # 共有Home Manager設定
│   ├── DE/                 # デスクトップ環境 (GNOME, KDE, Niri)
│   │   ├── gnome/
│   │   │   ├── gnome.nix   # Home Manager設定
│   │   │   └── nixos.nix   # NixOS設定
│   │   ├── kde/
│   │   │   ├── kde.nix
│   │   │   └── nixos.nix
│   │   └── niri/
│   │       ├── niri.nix
│   │       └── nixos.nix
│   └── examples/           # モジュールテンプレート例
│       └── service-template.nix
└── docs/                   # ドキュメント / Documentation
    ├── setup-guide.ja.md   # セットアップガイド (日本語)
    ├── setup-guide.en.md   # Setup Guide (English)
    └── architecture.ja.md  # 構成説明書 (日本語)
```

## 仕組み / Mechanism

1.  **マルチホスト**: `hosts/` ディレクトリ配下にマシンごとの設定を完全に分離して配置します。
2.  **共有モジュール**: デスクトップ環境のパッケージ構成や基本的なリンク処理は `modules/` で一元管理され、各ホストから必要に応じて読み込まれます。
3.  **変数の活用**: 各ホストの `variables.nix` で、ユーザー名、ホスト名、有効にするDE、設定ファイルのパスなどを一括管理します。
4.  **ホスト固有モジュール**: 各ホストは `modules/default.nix` を持ち、ホスト固有の追加モジュールを定義できます。

詳細な構造と仕組みについては、[**構成説明書 (日本語)**](./docs/architecture.ja.md) を参照してください。

## セットアップ手順 / Getting Started

詳細なセットアップ手順については、以下のガイドを参照してください。

- [**セットアップガイド (日本語)**](./docs/setup-guide.ja.md)
- [**Setup Guide (English)**](./docs/setup-guide.en.md)

### クイックスタート (既設ホストの適用)

```bash
sudo nixos-rebuild switch --flake .#desktop
```

## 主要なコマンド / Key Commands

- **設定の適用**: `sudo nixos-rebuild switch --flake .#<hostname>`
- **パッケージ更新**: `nix flake update`

## ライセンス / License

このプロジェクトは **MIT License** の下で公開されています。

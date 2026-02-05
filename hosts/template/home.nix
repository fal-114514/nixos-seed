# =============================================================================
# Home Manager Configuration / Home Manager設定
# =============================================================================
# This file manages user-specific packages and configurations.
# このファイルはユーザー固有のパッケージと設定を管理します。
# =============================================================================

{ config, pkgs, var, ... }:

{
  imports = [
    ./modules
    ../../modules/home.nix
  ];

  # ===========================================================================
  # User Information / ユーザー情報
  # ===========================================================================
  # Retrieved from variables.nix / variables.nixから取得
  home.username = var.user.name;
  home.homeDirectory = "/home/${var.user.name}";

  # State Version / ステートバージョン

  home.stateVersion = var.system.stateVersion;

  # Link DE configuration files / DE設定ファイルのリンク
  # Managed by imported modules (see ./DE/*)
  # インポートされたモジュールで管理されます (./DE/* を参照)
  xdg.configFile = {
    # Common configurations can go here / 共通の設定はここに記述
  };

  # ===========================================================================
  # Tool Configurations / ツール設定
  # ===========================================================================

  # Git Configuration / Git設定
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = var.user.gitUsername;
        email = var.user.gitEmail;
      };
    };
  };

  # Terminal Prompt (Starship) / ターミナルプロンプト
  programs.starship.enable = true;

  # Terminal Emulator (Ghostty) / ターミナルエミュレータ
  programs.ghostty = {
    enable = true;
  };

  # Shell History (Atuin) / シェル履歴
  programs.atuin = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      auto_sync = true;
      update_check = false;
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  # ===========================================================================
  # User Packages / ユーザーパッケージ
  # ===========================================================================
  home.packages = with pkgs; [
    # ---------------------------------------------------------------------------
    # System Utilities / システムユーティリティ
    # ---------------------------------------------------------------------------
    wget              # Download utility / ダウンロードユーティリティ
    curl              # URL transfer utility / URL転送ユーティリティ
    zip               # Zip archiving / Zipアーカイブ
    unzip             # Zip extraction / Zip展開
    p7zip             # 7-Zip support / 7-Zipサポート
    rar               # Rar support / Rarサポート
    gnutar            # Tar utility / Tarユーティリティ
    iproute2          # Network tools / ネットワークツール
    unixtools.ping    # Ping tool / Pingツール
    
    # ---------------------------------------------------------------------------
    # Development / 開発
    # ---------------------------------------------------------------------------
    gcc               # C Compiler / Cコンパイラ
    pkg-config
    vim               # Text Editor / テキストエディタ
    
    # Development Libraries / 開発ライブラリ
    glib
    glib.dev
    gtk3.dev
    pango.dev
    cairo.dev
    gdk-pixbuf

    # ---------------------------------------------------------------------------
    # Hardware Tools / ハードウェアツール
    # ---------------------------------------------------------------------------
    light             # Backlight control / バックライト制御
    brightnessctl     # Brightness control / 輝度制御
    parted            # Partition tool / パーティションツール
    
    # ---------------------------------------------------------------------------
    # Desktop Tools / デスクトップツール
    # ---------------------------------------------------------------------------
    mangohud          # Gaming overlay / ゲーミングオーバーレイ
    xdg-utils
    
    # File Managers / ファイルマネージャー
    nnn               # Terminal FM / ターミナルFM
    pcmanfm           # GUI FM / GUI FM

    # ---------------------------------------------------------------------------
    # Applications / アプリケーション
    # ---------------------------------------------------------------------------
    vivaldi           # Web Browser / Webブラウザ
    vesktop           # Discord Client / Discordクライアント
    
    # Download Managers / ダウンロードマネージャー
    motrix
    aria2
    
    # Miscellaneous / その他
    plymouth          # Boot splash / ブートスプラッシュ

    # Wine (Windows Compatibility)
    wineWow64Packages.full
  ];
}

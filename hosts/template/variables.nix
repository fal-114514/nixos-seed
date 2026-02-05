# =============================================================================
# NixOS Configuration Variables / NixOS設定変数
# =============================================================================
# This file contains all user-specific variables for easy customization.
# このファイルには簡単にカスタマイズできるユーザー固有の変数が含まれています。
# =============================================================================

{
  # ---------------------------------------------------------------------------
  # User Configuration / ユーザー設定
  # ---------------------------------------------------------------------------
  user = {
    # Username / ユーザー名
    name = "username";
    
    # User description (Full Name) / ユーザーの説明（フルネーム）
    description = "Please Enter Your Name";
    
    # Default shell / デフォルトシェル
    # Options: pkgs.bash, pkgs.zsh, pkgs.fish, pkgs.nushell
    shell = "pkgs.nushell";

    # Git Configuration / Git設定
    gitUsername = "Your Git Username";
    gitEmail = "you@example.com";
  };

  # ---------------------------------------------------------------------------
  # System Configuration / システム設定
  # ---------------------------------------------------------------------------
  system = {
    # Hostname / ホスト名
    hostname = "nixos-template";
    
    # System architecture / システムアーキテクチャ
    architecture = "x86_64-linux";

    # VM identification / VM環境かどうかの識別
    # Set to true if installing in VirtualBox, VMware, etc.
    # VirtualBox、VMware等にインストールする場合はtrueに設定してください
    isVM = true;
    
    # State version (do not change after initial installation)
    # ステートバージョン（初回インストール後は変更しないでください）
    stateVersion = "25.11";
    
    # Time zone / タイムゾーン
    timeZone = "Asia/Tokyo";
    
    # Default locale / デフォルトロケール
    defaultLocale = "en_US.UTF-8";
    
    # Additional locales (Date, Currency, etc.) / 追加ロケール（日付、通貨など）
    extraLocale = "ja_JP.UTF-8";
  };

  # ---------------------------------------------------------------------------
  # Desktop Environment / デスクトップ環境
  # ---------------------------------------------------------------------------
  desktop = {
    # Enable Gnome (Default for beginners) / Gnomeを有効化（初心者向けデフォルト）
    enableGnome = true;
    gnomeConfigPath = ./config/DE/gnome/default.nix;

    # Enable Niri (Tiling WM) / Niriを有効化（タイル型WM）
    enableNiri = true;
    niriConfigPath = ./config/DE/niri/config.kdl;

    # Enable KDE Plasma / KDE Plasmaを有効化
    enableKde = false;
    kdeConfigPath = ./config/DE/kde/default.nix;

    # Login Manager / ログインマネージャー
    # Options: "regreet", "tuigreet", "gdm", "sddm", "lemurs"
    # オプション: "regreet", "tuigreet", "gdm", "sddm", "lemurs"
    # Note: "regreet" may have issues in some VMs. Use "tuigreet", "gdm", or "lemurs" for stability.
    # 注意: "regreet"は一部のVMで問題が発生する可能性があります。安定性のために"tuigreet"、"gdm"、または"lemurs"を使用してください。
    displayManager = "tuigreet";
  };

  # ---------------------------------------------------------------------------
  # Network Configuration / ネットワーク設定
  # ---------------------------------------------------------------------------
  network = {
    # Enable NetworkManager / NetworkManagerを有効化
    enableNetworkManager = true;
    
    # Enable SSH / SSHを有効化
    enableSSH = true;

    # SSH Port / SSHポート
    sshPort = 22;
  };

  # ---------------------------------------------------------------------------
  # Input Method / 入力メソッド
  # ---------------------------------------------------------------------------
  inputMethod = {
    # Enable Japanese Input (Mozc) / 日本語入力（Mozc）を有効化
    enable = true;
    type = "fcitx5";
  };
  # ---------------------------------------------------------------------------
  # Custom Service Configuration (Example) / カスタムサービス設定（例）
  # ---------------------------------------------------------------------------
  # 新しいモジュール（例: modules/examples/service-template.nix）を追加した場合は、
  # 以下のように有効化フラグやパラメーターを定義します。
  # example-service = {
  #   enableExample = true;
  # };
}

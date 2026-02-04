# =============================================================================
# NixOS System Configuration / NixOSシステム設定
# =============================================================================
# This is the main system configuration file.
# これはメインのシステム設定ファイルです。
# =============================================================================

{ config, pkgs, var, ... }:

let
  # Helper function to get shell package from string
  # 文字列からシェルパッケージを取得するヘルパー関数
  getShell = shellStr: 
    if shellStr == "pkgs.bash" then pkgs.bash
    else if shellStr == "pkgs.zsh" then pkgs.zsh
    else if shellStr == "pkgs.fish" then pkgs.fish
    else if shellStr == "pkgs.nushell" then pkgs.nushell
    else pkgs.bash;
in
{
  imports =
    [ # Include hardware configuration / ハードウェア設定を含める
      # If you haven't generated it yet, run 'nixos-generate-config'
      # まだ生成していない場合は、'nixos-generate-config'を実行してください
      ./hardware-configuration.nix
    ];

  # ===========================================================================
  # Boot Configuration / ブート設定
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ===========================================================================
  # Network Configuration / ネットワーク設定
  # ===========================================================================
  
  # Hostname / ホスト名
  networking.hostName = var.system.hostname;

  # Network Manager / ネットワーク管理
  networking.networkmanager.enable = var.network.enableNetworkManager;

  # SSH Configuration / SSH設定
  # SSH Configuration / SSH設定
  services.openssh = {
    enable = var.network.enableSSH;
    ports = [ var.network.sshPort ];
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };
  networking.firewall.allowedTCPPorts = [ var.network.sshPort ];

  # ===========================================================================
  # System Limits & Performance / システム制限とパフォーマンス
  # ===========================================================================
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
  ];

  # ===========================================================================
  # Localization / ローカライゼーション
  # ===========================================================================

  # Time Zone / タイムゾーン
  time.timeZone = var.system.timeZone;

  # Locale / ロケール
  i18n = {
    defaultLocale = var.system.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = var.system.extraLocale;
      LC_IDENTIFICATION = var.system.extraLocale;
      LC_MEASUREMENT = var.system.extraLocale;
      LC_MONETARY = var.system.extraLocale;
      LC_NAME = var.system.extraLocale;
      LC_NUMERIC = var.system.extraLocale;
      LC_PAPER = var.system.extraLocale;
      LC_TELEPHONE = var.system.extraLocale;
      LC_TIME = var.system.extraLocale;
    };

    # Input Method (Japanese) / 入力メソッド（日本語）
    inputMethod = {
      enable = var.inputMethod.enable;
      type = var.inputMethod.type;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
      ];
    };
  };

  # Fonts / フォント
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # ===========================================================================
  # Audio / オーディオ
  # ===========================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===========================================================================
  # Desktop Environment / デスクトップ環境
  # ===========================================================================
  
  # Enable XServer (Required for Gnome) / XServerを有効化（Gnomeに必要）
  # Enable XServer (Required for Gnome, etc.) / XServerを有効化（Gnome等に必要）
  services.xserver.enable = var.desktop.enableGnome;
  
  # ---------------------------------------------------------------------------
  # Login Manager / ログインマネージャー
  # ---------------------------------------------------------------------------

  # GDM (Gnome Display Manager) / GDM（Gnomeディスプレイマネージャー）
  services.displayManager.gdm.enable = (var.desktop.displayManager == "gdm");

  # SDDM (Simple Desktop Display Manager) / SDDM
  services.displayManager.sddm.enable = (var.desktop.displayManager == "sddm");

  # Lemurs (Terminal Login Manager) / Lemurs（ターミナルログインマネージャー）
  services.displayManager.lemurs.enable = (var.desktop.displayManager == "lemurs");

  # ReGreet (GTK based Greeter) / ReGreet（GTKベースのグリーター）
  programs.regreet.enable = (var.desktop.displayManager == "regreet");
  
  # Greetd Configuration (for Tuigreet and ReGreet) 
  # Greetd設定（TuigreetおよびReGreet用）
  services.greetd = {
    enable = (var.desktop.displayManager == "tuigreet" || var.desktop.displayManager == "regreet");
    settings = {
      default_session = {
        command = 
          if var.desktop.displayManager == "regreet" then
            "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.regreet}/bin/regreet"
          else if var.desktop.displayManager == "tuigreet" then
            "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions ${pkgs.niri}/share/wayland-sessions:${pkgs.gnome-session}/share/wayland-sessions"
          else
            # Fallback
            "${pkgs.tuigreet}/bin/tuigreet --time --remember --sessions ${pkgs.niri}/share/wayland-sessions:${pkgs.gnome-session}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # TTY control for Greetd (Prevents visual glitches)
  # GreetdのTTY制御（表示乱れを防止）
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
    VTNr = 1;
  };

  # Gnome Desktop / Gnomeデスクトップ
  services.displayManager.gnome.enable = var.desktop.enableGnome;

  # Niri (Window Manager) / Niri（ウィンドウマネージャー）
  programs.niri.enable = var.desktop.enableNiri;

  # Session Variables / セッション変数
  environment.sessionVariables = {
    # Wayland / Niri settings
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    
    # Input Method
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # ===========================================================================
  # User Account / ユーザーアカウント
  # ===========================================================================
  users.users.${var.user.name} = {
    isNormalUser = true;
    description = var.user.description;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = getShell var.user.shell;
  };

  # ===========================================================================
  # System Packages / システムパッケージ
  # ===========================================================================
  
  # Allow unfree packages / 非フリーパッケージを許可
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Tools / コアツール
    git
    vim
    
    # Dependencies / 依存関係
    adwaita-icon-theme # For ReGreet
  ];

  # Flatpak support / Flatpakサポート
  services.flatpak.enable = true;

  # Virtualization / 仮想化
  virtualisation.libvirtd.enable = true;

  # Binary compatibility / バイナリ互換性
  programs.nix-ld.enable = true;

  # ===========================================================================
  # System State / システム状態
  # ===========================================================================
  system.stateVersion = var.system.stateVersion;
  
  # Experimental features / 実験的機能
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Lemurs Session Scripts / Lemursセッションスクリプト
  environment.etc = {
    "lemurs/wayland/Niri".text = ''
      #!${pkgs.bash}/bin/bash
      exec niri-session
    '';
    "lemurs/wayland/Gnome".text = ''
      #!${pkgs.bash}/bin/bash
      exec gnome-session
    '';
  };
}

# =============================================================================
# NixOS System Configuration / NixOSシステム設定
# =============================================================================
# This is the main system configuration file.
# これはメインのシステム設定ファイルです。
# =============================================================================

{ config, pkgs, var, lib, ... }:

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
      # Include host-local and shared modules / ホスト固有および共有モジュールを含める
      ./modules
    ];

  # ===========================================================================
  # Boot Configuration / ブート設定
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Early load graphics driver for VirtualBox (if isVM is true)
  # VirtualBox用のグラフィックスドライバを早期読み込み（isVMがtrueの場合）
  boot.initrd.kernelModules = if var.system.isVM then [ "vmwgfx" ] else [ ];

  # ===========================================================================
  # Network Configuration / ネットワーク設定
  # ===========================================================================

  # Hostname / ホスト名
  networking.hostName = var.system.hostname;

  # Network Manager / ネットワーク管理
  networking.networkmanager.enable = var.network.enableNetworkManager;

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

  # Set hardware clock to local time (for dual-boot with Windows)
  # ハードウェアクロックをローカルタイムに設定（Windowsとのデュアルブート用）
  time.hardwareClockInLocalTime = true;

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
    # Use the input method defined in variables.nix
    # variables.nix で定義された入力メソッドを使用
    inputMethod = {
      enable = var.inputMethod.enable;
      type = var.inputMethod.type;
      ibus.engines = lib.mkIf (var.inputMethod.type == "ibus") (with pkgs.ibus-engines; [ mozc ]);
      fcitx5.addons = lib.mkIf (var.inputMethod.type == "fcitx5") (with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ]);
      fcitx5.waylandFrontend = (var.inputMethod.type == "fcitx5");
      # デフォルトを Mozc（日本語）にし、レイアウトを jp に（「日本語」選択時に実際に変換できるようにする）
      fcitx5.settings.inputMethod = lib.mkIf (var.inputMethod.type == "fcitx5") {
        "GroupOrder" = { "0" = "Default"; };
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = var.inputMethod.fcitx5Layout;
          DefaultIM = "mozc";
        };
        "Groups/0/Items/0" = { Name = "keyboard-${var.inputMethod.fcitx5Layout}"; };
        "Groups/0/Items/1" = { Name = "mozc"; };
      };
    };
  };

  services.xserver.xkb = {
    layout = var.inputMethod.fcitx5Layout;
    variant = "";
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

  # Enable XServer (Required for Gnome, KDE, etc.) / XServerを有効化（Gnome、KDE等に必要）
  services.xserver.enable = var.desktop.enableGnome || var.desktop.enableKde;

  # ---------------------------------------------------------------------------
  # Login Manager / ログインマネージャー
  # ---------------------------------------------------------------------------

  # GDM (Gnome Display Manager) / GDM（Gnomeディスプレイマネージャー）
  services.displayManager.gdm.enable = (var.desktop.displayManager == "gdm");

  # SDDM (Simple Desktop Display Manager) / SDDM
  services.displayManager.sddm.enable = (var.desktop.displayManager == "sddm");

  # Lemurs (Terminal Login Manager) / Lemurs（ターミナルログインマネージャー）
  # services.displayManager.lemurs.enable = (var.desktop.displayManager == "lemurs");

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
            "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions"
          else
            # Fallback
            "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions";
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
  services.desktopManager.gnome.enable = var.desktop.enableGnome;

  # KDE Plasma Desktop / KDE Plasmaデスクトップ
  services.desktopManager.plasma6.enable = var.desktop.enableKde;

  # SSH AskPassword の競合を解決（Gnome と KDE の両方が有効な場合）
  # Gnome の seahorse を優先し、KDE 単独の場合は ksshaskpass を使用
  programs.ssh.askPassword = lib.mkIf (var.desktop.enableGnome && var.desktop.enableKde)
    (lib.mkForce "${pkgs.gnome-keyring}/libexec/seahorse/ssh-askpass");

  # Niri (Window Manager) / Niri（ウィンドウマネージャー）
  programs.niri.enable = var.desktop.enableNiri;

  # Session Variables / セッション変数
  environment.sessionVariables = {
    # Wayland / DE specific settings
    # 選択されたデスクトップ環境に応じて動的に設定
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = if var.desktop.enableNiri then "niri"
                          else if var.desktop.enableGnome then "gnome"
                          else if var.desktop.enableKde then "kde"
                          else "sway"; # Fallback
    XDG_SESSION_DESKTOP = if var.desktop.enableNiri then "niri"
                          else if var.desktop.enableGnome then "gnome"
                          else if var.desktop.enableKde then "kde"
                          else "sway"; # Fallback
    # Input Method（Qt/GTK アプリが IM を使うために必要。KDE で「日本語」選択時に英語のままになるのはこれが未設定のため）
    GTK_IM_MODULE = if var.inputMethod.type == "ibus" then "ibus" else "fcitx";
    QT_IM_MODULE = if var.inputMethod.type == "ibus" then "ibus" else "fcitx";
    XMODIFIERS = if var.inputMethod.type == "fcitx5" then "@im=fcitx" else "@im=ibus";

    # IBus の場合、デーモンアドレスを設定
    IBUS_DAEMON_ADDRESS = lib.mkIf (var.inputMethod.type == "ibus") "unix:path=/run/user/1000/ibus/ibus-daemon";
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

    # Input Method Tools / 入力メソッドツール
    qt6Packages.fcitx5-configtool # For Fcitx5 configuration GUI
  ];

  # Flatpak support / Flatpakサポート
  services.flatpak.enable = true;

  # Virtualization / 仮想化
  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.guest.enable = var.system.isVM;

  # Binary compatibility / バイナリ互換性
  programs.nix-ld.enable = true;

  # ===========================================================================
  # System State / システム状態
  # ===========================================================================
  system.stateVersion = var.system.stateVersion;

  # Experimental features / 実験的機能
  # Nix settings / Nix設定
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}

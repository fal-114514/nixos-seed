{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
mkIf cfg.enableNiri {
  # Link configuration file / 設定ファイルをリンク
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # Niri specific packages / Niri固有のパッケージ
  home.packages = with pkgs; [
    xwayland-satellite  # XWayland support / XWaylandサポート
    xbindkeys           # Key binding utility / キーバインドツール
    swaybg              # Wallpaper utility (common for wlroots/niri) / 壁紙ユーティリティ
    
    # Add other Niri tools here / その他Niri用ツールをここに追加
  ];
}

{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
# -----------------------------------------------------------------------------
# niri モジュールの実装例
# variables.nix の `desktop.enableNiri` が true の場合のみ評価されます。
# -----------------------------------------------------------------------------
mkIf cfg.enableNiri {
  # Link configuration file / 設定ファイルをリンク
  # variables.nix に定義された外部設定ファイルのパスを参照します。
  xdg.configFile."niri/config.kdl".source = cfg.niriConfigPath;

  # Niri specific packages / Niri固有のパッケージ
  # このモジュールが有効な場合のみ、Home Manager プロファイルに追加されます。
  home.packages = with pkgs; [
    xwayland-satellite  # XWayland support / XWaylandサポート
    xbindkeys           # Key binding utility / キーバインドツール
    swaybg              # Wallpaper utility (common for wlroots/niri) / 壁紙ユーティリティ
    
    # Add other Niri tools here / その他Niri用ツールをここに追加
  ];
}

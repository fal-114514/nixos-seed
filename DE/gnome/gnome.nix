{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
mkIf cfg.enableGnome {
  # Gnome specific settings can go here / Gnome固有の設定はここに記述
  
  # Example: Gnome extensions / 例：Gnome拡張機能
  # home.packages = with pkgs; [
  #   gnomeExtensions.appindicator
  # ];
  
  # dconf settings / dconf設定
  # dconf.settings = { ... };
}

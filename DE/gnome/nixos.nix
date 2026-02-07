{ pkgs, lib, var, ... }:

{
  # Gnome Desktop / Gnomeデスクトップ
  services.desktopManager.gnome.enable = var.desktop.enableGnome;
}

{ pkgs, lib, var, ... }:

{
  # KDE Plasma Desktop / KDE Plasmaデスクトップ
  services.desktopManager.plasma6.enable = var.desktop.enableKde;
}

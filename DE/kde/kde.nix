{ pkgs, lib, var, ... }:

with lib;

let
  cfg = var.desktop;
in
mkIf (builtins.hasAttr "enableKde" cfg && cfg.enableKde) {
  # KDE specific settings can go here / KDE固有の設定はここに記述
}

{ pkgs, lib, var, ... }:

{
  imports = lib.optional var.desktop.enableGnome var.desktop.gnomeConfigPath;
}

{ pkgs, lib, var, ... }:

{
  imports = lib.optional (builtins.hasAttr "enableKde" var.desktop && var.desktop.enableKde) var.desktop.kdeConfigPath;
}

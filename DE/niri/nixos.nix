{ pkgs, lib, var, ... }:

{
  # Niri (Window Manager) / Niri（ウィンドウマネージャー）
  programs.niri.enable = var.desktop.enableNiri;
}

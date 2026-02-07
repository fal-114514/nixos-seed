{ pkgs, lib, var, ... }:
{
  # Niri (Window Manager) / Niri（ウィンドウマネージャー）
  # 実際には programs.niri.enable = true; などだが、ホストごとに細かい調整が必要な場合を考慮
  programs.niri.enable = var.desktop.enableNiri;
}

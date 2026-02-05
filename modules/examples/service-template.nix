# =============================================================================
# NixOS Module Template / NixOSモジュールテンプレート
# =============================================================================
# このファイルは新しいモジュール（サービスやデスクトップ環境など）を作成する際の
# テンプレートとして使用してください。
# =============================================================================

{ pkgs, lib, var, ... }:

with lib;

let
  # variables.nix で定義されたこのモジュール用の設定を取得
  # 例: variables.nix に service.docker = { enable = true; }; がある場合
  cfg = var.example-service; 
in
{
  # cfg.enable が true の場合のみ、このブロック内の設定が適用されます
  mkIf cfg.enableExample {
    
    # --- システムパッケージの追加 ---
    environment.systemPackages = with pkgs; [
      example-package
    ];

    # --- システムサービスの有効化 ---
    services.example-service.enable = true;

    # --- Home Manager 設定の注入 (オプション) ---
    # システム全体の設定だけでなく、ユーザー個別の設定もここで行えます
    # home-manager.users.${var.user.name} = {
    #   home.file.".config/example/config.conf".text = "some config";
    # };
  }
}

# -----------------------------------------------------------------------------
# 使い方 / How to use:
# 1. このファイルをコピーして `modules/` 配下に新しいファイルを作成します。
# 2. `hosts/*/variables.nix` に対応する有効化フラグ（例: `example-service.enable = true;`）を追加します。
# 3. `modules/default.nix` の `imports` に作成したファイルのパスを追加します。
# -----------------------------------------------------------------------------

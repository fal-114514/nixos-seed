# =============================================================================
# Nix Flake Configuration / Nix Flake設定
# =============================================================================
# This file defines the flake inputs and system configuration.
# このファイルはflakeの入力とシステム設定を定義します。
# =============================================================================

{
  description = "Personal NixOS Configuration / 個人的なNixOS設定";

  # ===========================================================================
  # Inputs / 入力
  # ===========================================================================
  inputs = {
    # NixOS Package Repository / NixOSパッケージリポジトリ
    # Using unstable channel for latest packages / 最新パッケージのためにunstableチャンネルを使用
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (User configuration management) / Home Manager（ユーザー設定管理）
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpak Management / Flatpak管理
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  # ===========================================================================
  # Outputs / 出力
  # ===========================================================================
  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs:
    let
      # Define a helper to generate host config / ホスト設定を生成するヘルパー関数
      mkHost = hostName: dir:
        let
          # Load variables file for this host / このホストの変数ファイルを読み込み
          var = import (dir + "/variables.nix");
          system = var.system.architecture;
        in nixpkgs.lib.nixosSystem {
          inherit system;

          # Pass arguments to modules / モジュールに引数を渡す
          specialArgs = { inherit inputs var; };

          modules = [
            # System Configuration / システム設定
            (dir + "/configuration.nix")

            # Flatpak Support / Flatpakサポート
            nix-flatpak.nixosModules.nix-flatpak

            # ---------------------------------------------------------------------
            # Home Manager Integration / Home Manager統合
            # ---------------------------------------------------------------------
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Import user configuration / ユーザー設定をインポート
              home-manager.users.${var.user.name} = import (dir + "/home.nix");

              # Backup existing files / 既存ファイルのバックアップ
              home-manager.backupFileExtension = "backup";

              # Pass variables to Home Manager / Home Managerにも変数を渡す
              home-manager.extraSpecialArgs = { inherit inputs var; };
            }
          ];
        };
    in
    {
      # =========================================================================
      # NixOS Configurations / NixOS設定
      # =========================================================================
      nixosConfigurations = {
        # Desktop Configuration / デスクトップ設定 (Personal / 個人用)
        desktop = mkHost "desktop" ./hosts/desktop;

        # Template Configuration / テンプレート設定
        nixos-template = mkHost "nixos-template" ./hosts/template;
      };
    };
}

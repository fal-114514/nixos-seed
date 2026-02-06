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
      # Load variables file / 変数ファイルの読み込み
      var = import ./variables.nix;
      
      # System Architecture / システムアーキテクチャ
      system = var.system.architecture;
    in
    {
      # =========================================================================
      # NixOS System Configuration / NixOSシステム設定
      # =========================================================================
      nixosConfigurations.${var.system.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        
        # Pass arguments to modules / モジュールに引数を渡す
        specialArgs = { inherit inputs var; };
        
        modules = [
          # System Configuration / システム設定
          ./configuration.nix
          
          # Hardware Configuration / ハードウェア設定
          ./hardware-configuration.nix
          
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
            home-manager.users.${var.user.name} = import ./home.nix;

            # Backup existing files / 既存ファイルのバックアップ
            home-manager.backupFileExtension = "backup";

            # Pass variables to Home Manager / Home Managerにも変数を渡す
            home-manager.extraSpecialArgs = { inherit inputs var; };
          }
        ];
      };
    };
}

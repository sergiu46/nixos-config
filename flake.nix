{
  description = "My NixOS systems with flakes, Home Manager, and declarative Flatpaks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      stateVersion = "25.11";

      # Helper function to generate host configurations
      mkHost =
        configName: modules:
        let
          # Import variables directly into userVars
          userVars = import ./modules/userVars.nix {
            inherit (nixpkgs) lib;
            inherit configName;
          };
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              stateVersion
              configName
              userVars
              ;
          };
          modules = [
            # Global Unstable Overlay
            (
              { ... }:
              {
                nixpkgs.overlays = [
                  (final: prev: {
                    unstable = import nixpkgs-unstable {
                      inherit system;
                      config = {
                        allowUnfree = true;
                        allowInsecurePredicate = (pkg: true);
                      };
                    };
                  })
                ];
              }
            )
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            {
              nixpkgs.hostPlatform = system;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit stateVersion configName userVars; };
              };
            }
          ]
          ++ modules;
        };
    in
    {
      nixosConfigurations = {
        Latitude-NIX = mkHost "Latitude-NIX" [
          ./hosts/Latitude-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
          ./users/denisa/denisa.nix
        ];

        Samsung-NIX = mkHost "Samsung-NIX" [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];
        Kingston-NIX = mkHost "Kingston-NIX" [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];
        ADATA-NIX = mkHost "ADATA-NIX" [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];
        Unraid-NIX = mkHost "Unraid-NIX" [
          ./hosts/Unraid-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];
      };
    };
}

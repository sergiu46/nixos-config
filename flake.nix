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
      userVars = import ./modules/vars.nix;
      overlayModule = (
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
      );

      # Common modules shared across all hosts
      commonModules = [
        overlayModule
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        {
          nixpkgs.hostPlatform = system;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit stateVersion userVars; };
        }
      ];
    in
    {
      nixosConfigurations = {
        # Latitude
        "${userVars.latitudeName}" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs stateVersion userVars; };
          modules = commonModules ++ [
            ./hosts/Latitude-NIX/configuration.nix
            ./users/sergiu/sergiu.nix
            ./users/denisa/denisa.nix
          ];
        };
        # Portable
        "${userVars.portableName}" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs stateVersion userVars; };
          modules = commonModules ++ [
            ./hosts/Portable-NIX/configuration.nix
            ./users/sergiu/sergiu.nix
          ];
        };
      };
    };
}

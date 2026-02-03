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

      # Overlay for unstable packages
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
        }
      ];
    in
    {
      nixosConfigurations = {

        # Latitude-NIX
        Latitude-NIX =
          let
            pName = "Latitude-NIX";
            # Path updated to ./modules/vars.nix
            currentVars = import ./modules/vars.nix { configName = pName; };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs stateVersion;
              configName = pName;
              userVars = currentVars;
            };
            modules = commonModules ++ [
              {
                home-manager.extraSpecialArgs = {
                  inherit stateVersion;
                  configName = pName;
                  userVars = currentVars;
                };
              }
              ./hosts/Latitude-NIX/configuration.nix
              ./users/sergiu/sergiu.nix
              ./users/denisa/denisa.nix
            ];
          };

        # Samsung-NIX
        Samsung-NIX =
          let
            pName = "Samsung-NIX";
            currentVars = import ./modules/vars.nix { configName = pName; };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs stateVersion;
              configName = pName;
              userVars = currentVars;
            };
            modules = commonModules ++ [
              {
                home-manager.extraSpecialArgs = {
                  inherit stateVersion;
                  configName = pName;
                  userVars = currentVars;
                };
              }
              ./hosts/Portable-NIX/configuration.nix
              ./users/sergiu/sergiu.nix
            ];
          };

        # Kingston-NIX
        Kingston-NIX =
          let
            pName = "Kingston-NIX";
            currentVars = import ./modules/vars.nix { configName = pName; };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs stateVersion;
              configName = pName;
              userVars = currentVars;
            };
            modules = commonModules ++ [
              {
                home-manager.extraSpecialArgs = {
                  inherit stateVersion;
                  configName = pName;
                  userVars = currentVars;
                };
              }
              ./hosts/Portable-NIX/configuration.nix
              ./users/sergiu/sergiu.nix
            ];
          };

      };
    };
}

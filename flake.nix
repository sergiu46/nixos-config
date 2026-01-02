{
  description = "NixOS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      stateVersion = "25.11";
    in
    {
      nixosConfigurations = {
        Latitude-NIX = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs stateVersion; };

          modules = [
            ./hosts/Latitude-NIX/configuration.nix
            ./users/sergiu/sergiu.nix
            ./users/denisa/denisa.nix
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit stateVersion; };
            }

          ];
        };

        Portable-NIX = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs stateVersion; };

          modules = [
            ./hosts/Portable-NIX/configuration.nix
            ./users/sergiu/sergiu.nix
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit stateVersion; };
            }

          ];
        };
      };
    };
}

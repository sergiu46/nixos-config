{
  description = "NixOS Flake for Sergiu and Denisa";

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
    in
    {
      nixosConfigurations = {
        Latitude-NIX = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/Latitude-NIX/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak

            { nixpkgs.config.permittedInsecurePackages = [ "ventoy-qt5-1.1.07" ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.denisa = import ./users/denisa/home.nix;
              home-manager.users.sergiu = import ./users/sergiu/home.nix;
            }
          ];
        };

        Portable-NIX = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/Portable-NIX/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak

            { nixpkgs.config.permittedInsecurePackages = [ "ventoy-qt5-1.1.07" ]; }

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.sergiu = import ./users/sergiu/home.nix;
            }
          ];
        };
      };
    };
}

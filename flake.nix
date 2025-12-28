{
  description = "NixOS Flake for Sergiu and Denisa";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # Stable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # Helper to pass unstable packages into modules
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations = {
        "Latitude-NIX" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ overlay-unstable ]; }
            ./hosts/Latitude-NIX/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak
            { nixpkgs.config.permittedInsecurePackages = [ "ventoy-qt5-1.1.07" ]; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sergiu = import ./users/sergiu/home.nix;
              home-manager.users.denisa = import ./users/denisa/home.nix;
            }
          ];
        };
        "Portable-NIX" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.overlays = [ overlay-unstable ]; }
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

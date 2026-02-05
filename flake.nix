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
    { self, nixpkgs, ... }@inputs:
    let
      # Load our custom helper and pass it ALL inputs
      mkHost = import ./modules/mkHost.nix inputs;

      # Defaults
      system = "x86_64-linux";
      stateVersion = "25.11";
    in
    {
      nixosConfigurations = {
        # Now use: mkHost "Name" "Arch" "Version" [Modules]
        Latitude-NIX = mkHost "Latitude-NIX" system stateVersion [
          ./hosts/Latitude-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
          ./users/denisa/denisa.nix
        ];

        Samsung-NIX = mkHost "Samsung-NIX" system stateVersion [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];

        Kingston-NIX = mkHost "Kingston-NIX" system stateVersion [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];

        ADATA-NIX = mkHost "ADATA-NIX" system stateVersion [
          ./hosts/Portable-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];

        Unraid-NIX = mkHost "Unraid-NIX" system stateVersion [
          ./hosts/Unraid-NIX/configuration.nix
          ./users/sergiu/sergiu.nix
        ];
      };
    };
}

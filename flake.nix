{
  description = "My NixOS systems with flakes, Home Manager, and declarative Flatpaks";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      mkHost = import ./modules/mkHost.nix inputs;
      system = "x86_64-linux";
      stateVersion = "25.11";
    in
    {
      nixosConfigurations = {

        Latitude-NIX = mkHost "Latitude-NIX" system stateVersion [
          ./hosts/latitude.nix
          ./users/sergiu/sergiu.nix
          ./users/denisa/denisa.nix
          ./modules/system.nix
          ./modules/zramSwap.nix
          ./modules/autoUpdate.nix
          ./modules/powerOffOnSleep.nix
          ./modules/packages.nix
          ./modules/packagesExtra.nix
          ./modules/printing.nix
          ./modules/flatpak.nix
          ./modules/roCEI/roCEI.nix
        ];

        Samsung-NIX = mkHost "Samsung-NIX" system stateVersion [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/syncConfig.nix
          ./modules/system.nix
          ./modules/packages.nix
          ./modules/printing.nix
          ./modules/tmpfs.nix
          ./modules/flatpak.nix
          ./modules/disableTPM.nix
          ./modules/zramSwap.nix
          ./modules/powerOffNoSleep.nix
          ./modules/f2fsErrors.nix
        ];

        Kingston-NIX = mkHost "Kingston-NIX" system stateVersion [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/syncConfig.nix
          ./modules/system.nix
          ./modules/packagesLite.nix
          ./modules/tmpfs.nix
          ./modules/disableTPM.nix
          ./modules/zramSwap.nix
          ./modules/powerOffNoSleep.nix
          ./modules/f2fsErrors.nix
        ];

        Unraid-NIX = mkHost "Unraid-NIX" system stateVersion [
          ./hosts/vm.nix
          ./users/sergiu/sergiu.nix
          ./modules/autoUpdate.nix
          ./modules/system.nix
          ./modules/packagesLite.nix
          ./modules/syncConfig.nix
          ./modules/zramSwap.nix
          ./modules/tmpfs.nix
        ];
      };
    };
}

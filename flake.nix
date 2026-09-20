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
      mkHost = import ./modules/core/mkHost.nix inputs;
      system = "x86_64-linux";
      stateVersion = "25.11";
    in
    {
      nixosConfigurations = {

        Latitude-NIX = mkHost "Latitude-NIX" system stateVersion [
          ./hosts/latitude.nix
          ./users/sergiu/sergiu.nix
          ./users/denisa/denisa.nix
          ./modules/core/system.nix
          ./modules/hardware/zramSwap.nix
          ./modules/services/autoUpdate.nix
          ./modules/services/powerOffOnSleep.nix
          ./modules/services/printing.nix
          ./modules/software/packages.nix
          ./modules/software/packagesExtra.nix
          ./modules/software/flatpak.nix
          ./modules/software/roCEI/roCEI.nix
        ];

        Samsung-NIX = mkHost "Samsung-NIX" system stateVersion [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/hardware/tmpfs.nix
          ./modules/hardware/disableTPM.nix
          ./modules/hardware/zramSwap.nix
          ./modules/hardware/f2fsErrors.nix
          ./modules/hardware/udevRules.nix
          ./modules/services/syncConfig.nix
          ./modules/services/printing.nix
          ./modules/services/powerOffNoSleep.nix
          ./modules/software/packages.nix
          ./modules/software/flatpak.nix
        ];

        Kingston-NIX = mkHost "Kingston-NIX" system stateVersion [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/hardware/tmpfs.nix
          ./modules/hardware/disableTPM.nix
          ./modules/hardware/zramSwap.nix
          ./modules/hardware/f2fsErrors.nix
          ./modules/hardware/udevRules.nix
          ./modules/services/syncConfig.nix
          ./modules/services/printing.nix
          ./modules/services/powerOffNoSleep.nix
          ./modules/software/packages.nix
          ./modules/software/flatpak.nix
        ];

        Unraid-NIX = mkHost "Unraid-NIX" system stateVersion [
          ./hosts/vm.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/hardware/zramSwap.nix
          ./modules/hardware/tmpfs.nix
          ./modules/services/autoUpdate.nix
          ./modules/services/syncConfig.nix
          ./modules/software/packagesLite.nix
        ];
      };
    };
}

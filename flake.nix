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
    in
    {
      nixosConfigurations = builtins.mapAttrs (name: hostFn: hostFn name) {

        Latitude-NIX = mkHost system "25.11" [
          ./hosts/latitude.nix
          ./users/sergiu/sergiu.nix
          ./users/denisa/denisa.nix
          ./modules/core/system.nix
          ./modules/core/network.nix
          ./modules/core/plymouth.nix
          ./modules/hardware/zramSwap.nix
          ./modules/services/autoUpdate.nix
          ./modules/services/powerOffOnSleep.nix
          ./modules/services/printing.nix
          ./modules/software/packagesExtra.nix
          ./modules/software/flatpak.nix
          ./modules/software/roCEI.nix
        ];

        BAR-Plus = mkHost system "25.11" [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/core/network.nix
          ./modules/core/plymouth.nix
          ./modules/hardware/portable.nix
          ./modules/services/syncConfig.nix
          ./modules/services/printing.nix
          ./modules/services/powerOffNoSleep.nix
          ./modules/software/packagesDefault.nix
        ];

        FIT-Plus = mkHost system "25.11" [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/core/network.nix
          ./modules/core/plymouth.nix
          ./modules/hardware/portable.nix
          ./modules/services/syncConfig.nix
          ./modules/services/powerOffNoSleep.nix
          ./modules/software/packagesLite.nix
        ];

        Kingston = mkHost system "26.05" [
          ./hosts/portable.nix
          ./users/sergiu/sergiu.nix
          ./modules/core/system.nix
          ./modules/core/network.nix
          ./modules/core/plymouth.nix
          ./modules/hardware/portable.nix
          ./modules/services/syncConfig.nix
          ./modules/services/powerOffNoSleep.nix
          ./modules/software/packagesLite.nix
        ];

        Unraid-NIX = mkHost system "25.11" [
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

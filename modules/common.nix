{ inputs, system, stateVersion, configName, userVars, ... }:

{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.home-manager.nixosModules.home-manager
  ];

  # Global Unstable Overlay
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = { 
          allowUnfree = true; 
          allowInsecurePredicate = (pkg: true); 
        };
      };
    })
  ];

  nixpkgs.hostPlatform = system;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit stateVersion configName userVars; };
  };
}

{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  nix-flatpak,
  ...
}@inputs:

# This is the actual mkHost function
configName: system: stateVersion: modules:
let
  # Import variables directly into userVars
  userVars = import ../modules/userVars.nix {
    inherit (nixpkgs) lib;
    inherit configName;
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit
      inputs
      stateVersion
      configName
      userVars
      ;
  };
  modules = [
    # Global Unstable Overlay
    (
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
    )
    nix-flatpak.nixosModules.nix-flatpak
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit stateVersion configName userVars; };
      };
    }
  ]
  ++ modules;
}

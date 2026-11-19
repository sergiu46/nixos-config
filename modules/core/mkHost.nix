{
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  nix-flatpak,
  ...
}@inputs:

system: stateVersion: modules: configName:
let
  # Import variables directly into userVars
  userVars = import ./userVars.nix {
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
          (
            final: prev:
            let
              mkUnstable =
                extraConfig:
                import nixpkgs-unstable {
                  inherit system;
                  config = {
                    allowUnfree = true;
                  }
                  // extraConfig;
                };
            in
            {
              unstable = mkUnstable { }; # unstable, insecure rejected
              insecure = mkUnstable { allowInsecurePredicate = _: true; }; # unstable, insecure accepted
            }
          )
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

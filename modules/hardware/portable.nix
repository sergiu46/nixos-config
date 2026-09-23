{ ... }:

{
  imports = [
    ./disableTPM.nix
    ./f2fsErrors.nix
    ./tmpfs.nix
    ./udevRules.nix
    ./zramSwap.nix
  ];

}

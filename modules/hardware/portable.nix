{ ... }:

{
  imports = [
    ./disableTPM.nix
    ./tmpfs.nix
    ./udevRules.nix
    ./zramSwap.nix
  ];

}

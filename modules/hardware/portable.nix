{ ... }:

{
  imports = [
    ./disableTPM.nix
    ./tmpfs.nix
    ./zramSwap.nix
    ./scrollFactor.nix
  ];

}

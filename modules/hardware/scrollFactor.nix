{ inputs, ... }:

{
  imports = [ inputs.wsf.nixosModules.default ];
  programs.wsf.enable = true;
}

{ config, pkgs, ... }:

{
  # This allows the insecure package specifically for Home Manager
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-gtk3-1.1.07"
  ];

  home.packages = with pkgs; [
    ventoy-full-gtk
  ];
}

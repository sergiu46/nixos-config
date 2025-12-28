{ pkgs, ... }:
{

  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";

  home.packages = with pkgs; [
    unstable.bitwarden-desktop
    gnomeExtensions.just-perfection
    gnomeExtensions.system-monitor
    gnomeExtensions.dash-to-dock
    ventoy-full-qt
  ];

  imports = [
    ./vscode/vscode.nix

  ];

  home.shellAliases = {
    switch = "sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    check = "nixos-rebuild build --flake ~/NixOS#Latitude-NIX";
    upswitch = "sudo nix flake update ~/NixOS && sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    mount-portable = "sudo sudo mount /dev/disk/by-label/NIXROOT /mnt && sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot";
    install-portable = "sudo nixos-install --flake .#Portable-NIX";
  };

  # home-manager.users.sergiu = {
  #   dconf = {
  #     enable = true;
  #     settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  #   };
  # };

  programs.bash.enable = true;

  home.stateVersion = "25.11";
}

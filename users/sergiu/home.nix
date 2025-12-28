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
    switch-latitude = "sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    check-latitude = "nixos-rebuild build --flake ~/NixOS#Latitude-NIX";
    boot-latitude = "sudo nixos-rebuild boot --flake ~/NixOS#Latitude-NIX";
    update-latitude = "sudo nix flake update ~/NixOS && sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";

    switch-portable = "sudo nixos-rebuild switch --flake ~/NixOS#Portable-NIX";
    check-portable = "nixos-rebuild build --flake ~/NixOS#Portable-NIX";
    boot-portable = "sudo nixos-rebuild boot --flake ~/NixOS#Portable-NIX";
    update-portable = "sudo nix flake update ~/NixOS && sudo nixos-rebuild switch --flake ~/NixOS#Portable-NIX";
    mount-portable = "sudo mount /dev/disk/by-label/NIXROOT /mnt && sudo mkdir /mnt/boot && sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot";
    install-portable = "sudo nixos-install --flake ~/NixOS#Portable-NIX";
  };

  dconf = {
    enable = true;

    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.bash.enable = true;

  home.stateVersion = "25.11";
}

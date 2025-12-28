{ pkgs, stateVersion, ... }:
{

  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;

  home.packages = with pkgs; [
    bitwarden-desktop
    gnomeExtensions.just-perfection
    gnomeExtensions.system-monitor
    gnomeExtensions.dash-to-dock
    ventoy-full-qt
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Sergiu";
      user.email = "sergiu@example.com";
    };
  };

  imports = [
    ./vscode/vscode.nix

  ];

  home.shellAliases = {
    switch-latitude = "sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    check-latitude = "nixos-rebuild build --flake ~/NixOS#Latitude-NIX";
    boot-latitude = "sudo nixos-rebuild boot --flake ~/NixOS#Latitude-NIX";
    update-latitude = "cd ~/NixOS && sudo nix flake update && sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";

    switch-portable = "sudo nixos-rebuild switch --flake ~/NixOS#Portable-NIX";
    check-portable = "nixos-rebuild build --flake ~/NixOS#Portable-NIX";
    boot-portable = "sudo nixos-rebuild boot --flake ~/NixOS#Portable-NIX";
    update-portable = "cd ~/NixOS && sudo nix flake update && sudo nixos-rebuild switch --flake ~/NixOS#Portable-NIX";
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

}

{ pkgs, stateVersion, ... }:
{

  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;

  programs.bash.enable = true;

  imports = [
    ./vscode/vscode.nix
  ];

  home.packages = with pkgs; [
    bitwarden-desktop
    gnomeExtensions.system-monitor
    gnomeExtensions.alphabetical-app-grid
    ventoy-full-qt
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Sergiu";
      user.email = "sergiu@example.com";
    };
  };

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

    clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          "system-monitor@paradoxxx.zero.gmail.com"
          "alphabetical-app-grid@stuarthayhurst"
        ];
      };
    };
  };

}

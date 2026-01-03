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

  # Configure the SSH Client to use bitwarden
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      setEnv = {
        TERM = "xterm-256color";
      };
      identityAgent = "~/.bitwarden-ssh-agent.sock";
    };
  };

  # Git setup
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

    mount-portable = "sudo mount /dev/disk/by-label/NIX-ROOT /mnt && sudo mkdir -p /mnt/boot && sudo mount /dev/disk/by-label/NIX-BOOT /mnt/boot";
    install-portable = "sudo nixos-install --flake ~/NixOS#Portable-NIX";

    clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d && nix store gc && nix store optimise";
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        show-battery-percentage = true;
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.alphabetical-app-grid.extensionUuid

        ];

        favorite-apps = [
          "com.microsoft.Edge.desktop"
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "com.github.iwalton3.jellyfin-media-player.desktop"
          "org.telegram.desktop.desktop"
          "com.microsoft.Edge.flextop.msedge-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "bitwarden.desktop"
        ];

      };
    };
  };

  qt = {
    enable = true;

    platformTheme = {
      name = "adwaita";
    };

    style = {
      name = "adwaita-dark";
    };
  };

}

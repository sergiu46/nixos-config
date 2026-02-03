{
  pkgs,
  stateVersion,
  userVars,
  ...
}:

{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
  imports = [
    ../../modules/vscode.nix
  ];

  # GNOME customization
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "suspend";
        sleep-inactive-ac-timeout = 7200;
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.alphabetical-app-grid.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
        ];
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "microsoft-edge.desktop"
          "firefox.desktop"
          "org.jellyfin.JellyfinDesktop.desktop"
          "org.telegram.desktop.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "bitwarden.desktop"
        ];
      };
    };
  };

  # QT dark theme
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

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
    # SYSTEM BUILD & CLEAN
    check = "nixos-rebuild build --flake ~/NixOS#$(hostname)";
    switch = "sudo nixos-rebuild switch --flake ~/NixOS#$(hostname)";
    boot = "sudo nixos-rebuild boot --flake ~/NixOS#$(hostname)";
    update = "cd ~/NixOS && sudo nix flake update && boot";

    # Clean
    clean = ''
      sudo nix-collect-garbage -d && \
      nix-collect-garbage -d && \
      nix store optimise && \
      flatpak uninstall --unused -y && \
      boot
    '';

    umount-btrfs = "sudo umount -R /mnt && echo 'Btrfs unmounted.'";
    umount-portable = "sudo umount /mnt/boot && sudo umount /mnt && echo 'Portable unmounted.'";
  };

  programs.bash.initExtra = ''
    # BTRFS (System Drive)
    format-btrfs() {
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep part
      read -p "Target device for Btrfs: " dev
      read -p "Enter Config Name (e.g., Latitude-NIX): " name
      [ -b "$dev" ] && \
      read -p "REALLY wipe $dev and label it '$name'? (y/N): " CONFIRM && \
      [ "$CONFIRM" == "y" ] && \
      sudo mkfs.btrfs -L "$name" -f "$dev" && \
      sudo mount "$dev" /mnt && \
      sudo btrfs subvolume create /mnt/@ && \
      sudo btrfs subvolume create /mnt/@home && \
      sudo btrfs subvolume create /mnt/@nix && \
      sudo umount /mnt && \
      echo "Btrfs $name initialized."
    }

    mount-btrfs() {
      read -p "Enter Config Name to mount: " name
      sudo mkdir -p /mnt && \
      sudo mount -t btrfs -o subvol=@,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt && \
      sudo mkdir -p /mnt/{home,nix,boot} && \
      sudo mount -t btrfs -o subvol=@home,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt/home && \
      sudo mount -t btrfs -o subvol=@nix,${userVars.btrfs.optsString} /dev/disk/by-label/"$name" /mnt/nix
      echo "Btrfs $name mounted."
    }

    # F2FS (Portable Drive)
    format-portable() {
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep part
      read -p "Device for F2FS: " dev
      read -p "Enter Config Name (e.g., Kingston-NIX): " name
      [ -b "$dev" ] && \
      read -p "REALLY wipe $dev and label it '$name'? (y/N): " CONFIRM && \
      [ "$CONFIRM" == "y" ] && \
      sudo umount -l "$dev" 2>/dev/null || true && \
      sudo mkfs.f2fs -f -l "$name" -O extra_attr,inode_checksum,sb_checksum,compression -o 5 "$dev"
    }

    mount-portable() {
      read -p "Enter Label Name to mount: " name
      sudo mkdir -p /mnt && \
      sudo mount -t f2fs -o ${userVars.f2fs.optsString} /dev/disk/by-label/"$name" /mnt && \
      sudo chattr +c /mnt && \
      sudo mkdir -p /mnt/boot && \
      sudo mount /dev/disk/by-label/NIXEFI /mnt/boot
      echo "Portable $name mounted."
    }

    install-system() {
      read -p "Enter Flake Host Name (e.g., Kingston-NIX): " name
      echo "Start: $(date +%T)"
      sudo nixos-install --flake ~/NixOS#"$name"
      echo "Finish: $(date +%T)"
    }
  '';

}

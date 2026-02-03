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
      lsblk -pn -o NAME,SIZE,TYPE,FSTYPE,LABEL | grep -E "part|disk"
      echo ""

      read -p "Target BOOT partition (e.g., /dev/sdb1): " dev_boot
      read -p "Target ROOT partition (e.g., /dev/sdb2): " dev_root
      read -p "Enter Config Name (e.g., Kingston-NIX): " name
      
      local efi_name=$(echo "''${name:0:4}" | tr '[:lower:]' '[:upper:]')EFI
      local root_name="$name"

      if [ -b "$dev_boot" ] && [ -b "$dev_root" ]; then
        echo "--------------------------------------------------"
        echo "PREPARING DRIVE FOR: $name"
        echo "BOOT: $dev_boot -> FAT32 (Label: $efi_name, Flags: boot, esp)"
        echo "ROOT: $dev_root -> F2FS  (Label: $root_name)"
        echo "--------------------------------------------------"
        read -p "REALLY wipe these partitions? (y/N): " CONFIRM
        
        if [ "$CONFIRM" == "y" ]; then
          sudo umount -l "$dev_boot" "$dev_root" 2>/dev/null || true
          
          echo "Formatting Boot partition as FAT32..."
          sudo mkfs.fat -F 32 -n "$efi_name" "$dev_boot"
          
          local disk=$(echo "$dev_boot" | sed 's/[0-9]*$//')
          local part_num=$(echo "$dev_boot" | grep -o '[0-9]*$')
          echo "Setting ESP and Boot flags on $disk partition $part_num..."
          sudo parted "$disk" set "$part_num" esp on
          sudo parted "$disk" set "$part_num" boot on
          
          echo "Formatting Root partition as F2FS..."
          sudo mkfs.f2fs -f -l "$root_name" -O extra_attr,inode_checksum,sb_checksum,compression -o 5 "$dev_root"
          
          echo "--------------------------------------------------"
          echo "Success! You can now run: mount-portable (select $name)"
        fi
      else
        echo "Error: Partition devices not found. Check your paths."
      fi
    }

    mount-portable() {
      read -p "Enter Config Name to mount (e.g., Kingston-NIX): " name
      local efi_name=$(echo "''${name:0:4}" | tr '[:lower:]' '[:upper:]')EFI
      
      sudo mkdir -p /mnt
      sudo mount -t f2fs -o ${userVars.f2fs.optsString} /dev/disk/by-label/"$name" /mnt && \
      sudo chattr +c /mnt && \
      sudo mkdir -p /mnt/boot && \
      sudo mount /dev/disk/by-label/"$efi_name" /mnt/boot
      echo "Mounted $name and $efi_name to /mnt"
    }

    install-system() {
      read -p "Enter Flake Host Name (e.g., Kingston-NIX): " name
      echo "Start: $(date +%T)"
      sudo nixos-install --flake ~/NixOS#"$name"
      echo "Finish: $(date +%T)"
    }
  '';
}

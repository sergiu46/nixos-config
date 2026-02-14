{ ... }:
{
  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "80%";
  boot.tmp.cleanOnBoot = true;

  # Browser Speedup: Profile-sync-daemon
  services.psd.enable = true;

  # Log Handling: Keep logs in RAM and limited in size
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=128M
    MaxRetentionSec=1day
    MaxFileSec=1hour
  '';

  # Fix edge identity
  systemd.services.setup-edge-identity = {
    description = "Persistent Microsoft Identity Link";

    # Wait for the home-manager activation service to finish first
    after = [
      "home-manager-sergiu.service"
      "graphical.target"
    ];
    requires = [ "home-manager-sergiu.service" ];

    # Change this from multi-user.target to only trigger on login
    wantedBy = [ "graphical.target" ];

    script = ''
      # Ensure the directory exists before symlinking
      mkdir -p /home/sergiu/.config/cache/Microsoft

      # Clean up and link
      ln -sfn /home/sergiu/.config/cache/Microsoft /home/sergiu/.cache/Microsoft
      chown -R sergiu:users /home/sergiu/.config/cache/Microsoft

      # Clear Edge locks
      rm -f /home/sergiu/.config/microsoft-edge/Singleton*
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Run as root to ensure we can fix permissions/symlinks regardless of HM state
    };
  };

  # Nix Settings
  systemd.services.nix-daemon.environment.TMPDIR = "/var/cache/nix-build";
  nix.settings = {
    sandbox = true;
    build-dir = "/var/cache/nix-build";
  };

  # tmpfs Drives
  fileSystems = {
    # .cache RAM drive
    "/home/sergiu/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "size=50%"
        "mode=0700"
        "uid=1000"
      ];
    };

    # Flatpak and other temporary files
    "/var/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50%"
        "mode=1777"
      ];
    };

    # System Logs
    "/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "nosuid"
        "nodev"
        "size=256M"
        "mode=0755"
      ];
    };

    # Nix build directory
    "/var/cache/nix-build" = {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "nosuid"
        "nodev"
        "size=80%"
        "mode=0755"
      ];
    };

    # systemd private cache
    "/var/cache/private" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=100M"
        "mode=0700"
      ];
    };

    # GNOME virtual filesystem metadata
    "/var/cache/gvfs-metadata" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50M"
        "mode=0755"
      ];
    };

    # CUPS print spool
    "/var/spool/cups" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=512M"
        "mode=0710"
      ];
    };

  };

}

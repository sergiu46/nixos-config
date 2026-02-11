{ ... }:
{
  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";
  boot.tmp.cleanOnBoot = true;

  # Nix Build Optimization (In RAM)
  nix.settings = {
    sandbox = true;
    build-dir = "/var/cache/nix-build";
  };

  # Ensure the Nix Daemon uses the RAM-backed build directory
  systemd.services.nix-daemon.environment.TMPDIR = "/var/cache/nix-build";

  # Browser Speedup: Profile-sync-daemon
  services.psd.enable = true;

  # Log Handling: Keep logs in RAM and limited in size
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  # Fix Edge identity persistance
  systemd.services.setup-edge-identity = {
    description = "Persistent Microsoft Identity Link";

    after = [
      "home-sergiu-.cache.mount"
      "local-fs.target"
    ];
    requires = [ "home-sergiu-.cache.mount" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      USB_PERSIST="/home/sergiu/.config/cache/Microsoft"
      RAM_CACHE="/home/sergiu/.cache/Microsoft"
      mkdir -p "$USB_PERSIST"
      ln -sfn "$USB_PERSIST" "$RAM_CACHE"
      chmod 700 "$USB_PERSIST"
      rm -f /home/sergiu/.config/microsoft-edge/Singleton*
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "sergiu";
      Group = "users";
    };
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

    # Nix Build Directory
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

    # System Logs
    "/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      neededForBoot = true;
      options = [
        "nosuid"
        "nodev"
        "size=100M"
        "mode=0755"
      ];
    };

    # Network State
    "/var/lib/dhcpcd" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=10M"
        "mode=0755"
      ];
    };

    # Font Cache
    "/var/cache/fontconfig" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50M"
        "mode=0755"
      ];
    };
  };

}

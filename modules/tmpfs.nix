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

    # Recent files list
    "/home/sergiu/.local/share/recently-used.xbel" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "size=1M"
        "mode=0600"
        "uid=1000"
      ];
    };

    # GNOME file metadata
    "/home/sergiu/.local/share/gvfs-metadata" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noatime"
        "nodev"
        "nosuid"
        "size=50M"
        "mode=0700"
        "uid=1000"
      ];
    };

  };

}

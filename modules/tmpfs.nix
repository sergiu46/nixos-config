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

  systemd.user.services.setup-edge-identity = {
    description = "Link Identity to USB after RAM mount is ready";
    wantedBy = [ "graphical-session.target" ];

    # This tells systemd to wait specifically for that cache mount unit
    after = [ "home-sergiu-.cache.mount" ];
    requires = [ "home-sergiu-.cache.mount" ];

    script = ''
      # 1. Ensure the persistent folder on the USB has strict user-only permissions
      mkdir -p /home/sergiu/.config/microsoft-edge/IdentityPersistence
      chmod 700 /home/sergiu/.config/microsoft-edge/IdentityPersistence

      # 2. Create the parent folder in the RAM cache
      mkdir -p /home/sergiu/.cache/Microsoft
      chmod 700 /home/sergiu/.cache/Microsoft

      # 3. Create the symlink
      ln -sfn /home/sergiu/.config/microsoft-edge/IdentityPersistence /home/sergiu/.cache/Microsoft/Edge
    '';
    serviceConfig.Type = "oneshot";
  };

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

    # Nix Build Directory (Prevents USB wear during updates)
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

    # Network State (Stops small writes every time you change Wi-Fi)
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

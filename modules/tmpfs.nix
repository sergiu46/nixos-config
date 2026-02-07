{ ... }:
{
  # Use tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";
  boot.tmp.cleanOnBoot = true;

  # Nix Build Optimization (In RAM)
  nix.settings = {
    sandbox = true;
    auto-optimise-store = true;
    # Align Nix build directory with our tmpfs mount below
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

  environment.sessionVariables = {
    "PASSWORD_STORE" = "gnome-keyring";
  };

  fileSystems = {
    # 1. User Cache (Makes the UI and apps feel instant)
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

    # 2. Nix Build Directory (Prevents USB wear during updates)
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

    # 3. System Logs
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

    # 4. Network State (Stops small writes every time you change Wi-Fi)
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

    # 5. Font Cache
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

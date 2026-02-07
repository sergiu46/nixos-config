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

  systemd.user.tmpfiles.rules = [
    "d /tmp/sergiu-cache 0700 sergiu users -"
    "L+ /home/sergiu/.cache - - - - /tmp/sergiu-cache"
  ];

  fileSystems = {
    # 1. User Cache (Makes the UI and apps feel instant)
    # "/home/sergiu/.cache" = {
    #   device = "tmpfs";
    #   fsType = "tmpfs";
    #   options = [
    #     "nosuid"
    #     "nodev"
    #     "relatime"
    #     "size=50%"
    #     "mode=1777"
    #   ];
    # };

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

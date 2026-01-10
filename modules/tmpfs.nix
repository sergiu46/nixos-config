{ ... }:
{

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  nix.settings.sandbox = true;
  nix.settings.auto-optimise-store = false;
  nix.settings.build-dir = "/var/cache/nix-build";
  systemd.services.nix-daemon.environment.TMPDIR = "/var/cache/nix-build";

  services.psd.enable = true;
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  fileSystems = {
    "/home/sergiu/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "relatime"
        "size=50%"
        "mode=1777"
      ];
    };
    "/var/cache/nix-build" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=50%"
        "mode=0755"
      ];
    };
    "/var/log" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=100M"
        "mode=0755"
      ];
    };
    "/var/cache/fontconfig" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "size=100M"
        "mode=0755"
      ];
    };
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
  };

}

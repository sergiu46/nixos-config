{
  fileSystems = {

    "/tmp" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=1777"
      ];
    };

    "/var/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "mode=1777"
        "size=4G"
      ];
    };

    "/home/sergiu/.cache" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0777"
      ];
    };

    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };

    "/var/spool" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=0755"
      ];
    };

    "/nix/var/nix/db" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=512M" ];
    };

  };

  nix.settings.auto-optimise-store = true;
}

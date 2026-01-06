{

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  nix.settings.auto-optimise-store = true;
  nix.settings.build-dir = "/tmp";

  fileSystems = {

    "/tmp" = {
      fsType = "tmpfs";
      options = [
        "size=50%"
        "mode=1777"
      ];
    };

    "/home/sergiu/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nosuid"
        "nodev"
        "relatime"
        "size=2G"
        "mode=1777"
      ];
    };

    # "/var/tmp" = {
    #   device = "tmpfs";
    #   fsType = "tmpfs";
    #   options = [
    #     "mode=1777"
    #     "size=25%"
    #   ];
    # };

    # "/home/sergiu/.cache" = {
    #   fsType = "tmpfs";
    #   options = [
    #     "size=50%"
    #     "mode=0777"
    #   ];
    # };

    "/var/log" = {
      fsType = "tmpfs";
      options = [
        "size=10%"
        "mode=0755"
      ];
    };

    # "/nix/var/nix/db" = {
    #   device = "tmpfs";
    #   fsType = "tmpfs";
    #   options = [ "size=512M" ];
    # };

  };

}

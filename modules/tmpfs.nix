{

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  nix.settings.auto-optimise-store = true;
  nix.settings.build-dir = "/var/cache/nix-build";

  services.journald.extraConfig = "Storage=volatile";
  services.psd.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/cache/nix-build 0755 nixbld nixbld - -"
  ];

  fileSystems = {
    # "/tmp" = {
    #   fsType = "tmpfs";
    #   options = [
    #     "size=50%"
    #     "mode=1777"
    #   ];
    # };

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
  };

}

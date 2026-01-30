{ ... }:
{
  # File systems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/33a9284e-70df-4f5c-b74f-36bc473b4850";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4804-E951";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

}

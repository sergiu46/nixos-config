{ userVars, ... }:

{
  # PERMANENT SYSTEM MOUNTS
  fileSystems."/" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@" ] ++ userVars.btrfs.optsList;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@home" ] ++ userVars.btrfs.optsList;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/${userVars.btrfs.label}";
    fsType = "btrfs";
    options = [ "subvol=@nix" ] ++ userVars.btrfs.optsList;
    neededForBoot = true;
  };

}

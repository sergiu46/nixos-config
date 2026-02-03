{ ... }:

let
  devicePath = "/dev/disk/by-label/NixOS";
  btrfsOpts = [
    "noatime"
    "compress=zstd:1"
    "ssd"
    "discard=async"
  ];
in
{
  fileSystems."/" = {
    device = devicePath;
    fsType = "btrfs";
    options = [ "subvol=@" ] ++ btrfsOpts;
  };

  fileSystems."/home" = {
    device = devicePath;
    fsType = "btrfs";
    options = [ "subvol=@home" ] ++ btrfsOpts;
  };

  fileSystems."/nix" = {
    device = devicePath;
    fsType = "btrfs";
    options = [ "subvol=@nix" ] ++ btrfsOpts;
  };

  fileSystems."/var/log" = {
    device = devicePath;
    fsType = "btrfs";
    options = [ "subvol=@log" ] ++ btrfsOpts;
  };

}

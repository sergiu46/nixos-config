{ configName, lib, ... }:

let
  # Define the lists here so we can use them in the strings below
  btrfsOpts = [
    "noatime"
    "compress=zstd:1"
    "ssd"
    "discard=async"
    "space_cache=v2"
  ];

  f2fsOpts = [
    "noatime"
    "lazytime"
    "nodiscard"
    "compress_algorithm=zstd:6"
    "compress_chksum"
    "compress_mode=fs"
    "compress_extension=*"
    "gc_merge"
    "atgc"
    "reserve_root=16384"
    "active_logs=2"
  ];

  userGroups = [
    "networkmanager"
    "video"
    "render"
    "i2c"
    "dialout"
    "uucp"
    "lp"
  ];

in
{

  inherit userGroups;

  # Where in home directory to store the config
  nixosConfigDir = "/.config/NixOS";

  # The account that owns this repo on disk.
  # Used only where there's no logged-in user.
  primaryUser = "sergiu";

  # Porable boot partition label
  efiLabel = "${lib.toUpper (builtins.substring 0 4 configName)}EFI";

  btrfs = {
    label = configName;
    optsList = btrfsOpts;
    optsString = lib.concatStringsSep "," btrfsOpts;
  };

  f2fs = {
    label = configName;
    optsList = f2fsOpts;
    optsString = lib.concatStringsSep "," f2fsOpts;
  };

}

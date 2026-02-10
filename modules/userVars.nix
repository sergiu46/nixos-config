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
    "compress_algorithm=zstd:1"
    "compress_chksum"
    "compress_mode=fs"
    "compress_extension=*"
    "atgc"
    "gc_merge"
    "flush_merge"
    "reserve_root=16384"
    "inline_xattr"
    "inline_data"
    "inline_dentry"
  ];
in
{
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

  # Porable boot partition label
  efiLabel = "${lib.toUpper (builtins.substring 0 4 configName)}EFI";
}

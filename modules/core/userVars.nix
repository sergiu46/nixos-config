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
    "compress_algorithm=zstd:1"
    "compress_chksum"
    "compress_mode=fs"
    "compress_extension=*"
    "nocompress_extension=mp4"
    "nocompress_extension=mkv"
    "nocompress_extension=avi"
    "nocompress_extension=mov"
    "nocompress_extension=mp3"
    "nocompress_extension=flac"
    "nocompress_extension=jpg"
    "nocompress_extension=jpeg"
    "nocompress_extension=png"
    "nocompress_extension=gif"
    "nocompress_extension=zip"
    "nocompress_extension=7z"
    "nocompress_extension=gz"
    "nocompress_extension=xz"
    "nocompress_extension=iso"
    "gc_merge"
    "atgc"
    "checkpoint_merge"
    "reserve_root=16384"
    "inline_xattr"
    "inline_data"
    "inline_dentry"
  ];
in
{

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

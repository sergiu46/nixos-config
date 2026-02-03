{ configName, lib, ... }:

rec {

  efiLabel = (lib.toUpper (builtins.substring 0 4 configName)) + "EFI";

  # Btrfs Master Settings (Internal Drive)
  btrfs = {
    label = configName;
    optsList = [
      "noatime"
      "compress=zstd:1"
      "ssd"
      "discard=async"
      "space_cache=v2"
    ];
    optsString = builtins.concatStringsSep "," btrfs.optsList;
  };

  # F2FS Master Settings (External/Portable Drive)
  f2fs = {
    label = configName;
    optsList = [
      "noatime"
      "lazytime"
      "compress_algorithm=zstd:1"
      "compress_chksum"
      "compress_mode=fs"
      "compress_extension=*"
      "atgc"
      "gc_merge"
      "flush_merge"
      "discard"
      "checkpoint_merge"
      "active_logs=2"
      "reserve_root=16384"
      "inline_xattr"
      "inline_data"
      "inline_dentry"
    ];
    optsString = builtins.concatStringsSep "," f2fs.optsList;
  };
}

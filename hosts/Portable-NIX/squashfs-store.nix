{
  config,
  lib,
  pkgs,
  ...
}:

let
  squashfsImage = "/nix/store.squashfs";
in
{
  # Build a squashfs image of the store at build time
  system.build.squashfsStore =
    pkgs.runCommand "nix-store-squashfs"
      {
        buildInputs = [ pkgs.squashfsTools ];
      }
      ''
        mkdir -p $out
        mksquashfs /nix/store $out/store.squashfs -comp zstd -Xcompression-level 19 -noappend
      '';

  # Install the squashfs image into the system closure
  environment.etc."store.squashfs".source = config.system.build.squashfsStore + "/store.squashfs";

  # Mount squashfs as read-only store
  fileSystems."/nix/store-ro" = {
    fsType = "squashfs";
    device = "/etc/store.squashfs";
    options = [
      "loop"
      "ro"
    ];
  };

  # Overlay tmpfs on top of squashfs
  fileSystems."/nix/store" = {
    fsType = "overlay";
    device = "overlay";
    options = [
      "lowerdir=/nix/store-ro"
      "upperdir=/nix/store-rw/upper"
      "workdir=/nix/store-rw/work"
    ];
  };

  # Writable layer in RAM
  fileSystems."/nix/store-rw" = {
    fsType = "tmpfs";
    options = [
      "mode=0755"
      "size=4G"
    ];
  };

  # Ensure directories exist early
  systemd.tmpfiles.rules = [
    "d /nix/store-rw 0755 root root -"
    "d /nix/store-rw/upper 0755 root root -"
    "d /nix/store-rw/work 0755 root root -"
  ];
}

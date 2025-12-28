{
  config,
  pkgs,
  ...
}:

let
  # Build a squashfs image of the system closure
  storeSquashfs =
    pkgs.runCommand "nix-store-squashfs"
      {
        buildInputs = [ pkgs.squashfsTools ];
      }
      ''
        mkdir -p $out
        mksquashfs ${config.system.build.toplevel} $out/store.squashfs \
          -comp zstd -Xcompression-level 19 -noappend
      '';
in
{
  # Expose it as a system output (optional)
  system.build.storeSquashfs = storeSquashfs;

  # Mount the squashfs image directly from the Nix store
  fileSystems."/nix/store-ro" = {
    device = "${storeSquashfs}/store.squashfs";
    fsType = "squashfs";
    options = [
      "loop"
      "ro"
    ];
    neededForBoot = true;
  };

  # Writable overlay layer in RAM
  fileSystems."/nix/store-rw" = {
    fsType = "tmpfs";
    options = [
      "mode=0755"
      "size=4G"
    ];
    neededForBoot = true;
  };

  # Overlay mount
  fileSystems."/nix/store" = {
    fsType = "overlay";
    device = "overlay";
    options = [
      "lowerdir=/nix/store-ro"
      "upperdir=/nix/store-rw/upper"
      "workdir=/nix/store-rw/work"
      "x-systemd.requires-mounts-for=/nix/store-ro"
      "x-systemd.requires-mounts-for=/nix/store-rw"
    ];
    neededForBoot = true;
  };

  # Ensure overlay dirs exist
  systemd.tmpfiles.rules = [
    "d /nix/store-rw 0755 root root -"
    "d /nix/store-rw/upper 0755 root root -"
    "d /nix/store-rw/work 0755 root root -"
  ];
}

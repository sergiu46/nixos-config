{
  pkgs,
  lib,
  modulesPath,
  stateVersion,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    ../../modules/sync-config.nix
    ../../modules/system.nix
    ../../modules/packages.nix
    ../../modules/tmpfs.nix
  ];

  # --- Boot & Kernel ---
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Load KVM modules for both vendors so virtualization works everywhere
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];
    kernelParams = [
      "initcall_parallel=1" # Faster boot
      "scsi_mod.use_blk_mq=1" # Multi-queue for storage
    ];

    initrd = {
      checkJournalingFS = true;
      systemd.enable = true;
      # Disable TPM
      systemd.tpm2.enable = false;
      # Broad hardware support for the USB stick to boot anywhere
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "mmc_block"
        "mmc_core"
        "nvme"
        "ohci_pci"
        "rtsx_pci"
        "sd_mod"
        "sdhci_acpi"
        "sdhci_pci"
        "sr_mod"
        "uas"
        "uhci_hcd"
        "usb_storage"
        "xhci_pci"
        "atkbd"
        "hid_generic"
      ];
    };

    # Optimized for running off a slow USB stick
    kernel.sysctl = {
      "vm.dirty_background_bytes" = 16777216; # 16MB
      "vm.dirty_bytes" = 33554432; # 32MB
      "vm.swappiness" = 100; # Aggressively use ZRAM
      "vm.vfs_cache_pressure" = 50; # Keep directory structure in RAM
    };

    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
    };

    supportedFilesystems = lib.mkAfter [
      "btrfs"
      "ext4"
      "f2fs"
      "ntfs"
      "vfat"
      "xfs"
    ];

    # Disable TPM modules
    blacklistedKernelModules = [
      "tpm"
      "tpm_tis"
      "tpm_tis_core"
      "tpm_crb"
    ];
  };

  # --- Filesystems ---
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/Portable-NIX";
      fsType = "f2fs";
      options = [
        "noatime"
        "lazytime"
        "background_gc=sync"
        "compress_algorithm=lz4"
        "compress_chksum"
        "compress_mode=fs"
        "compress_extension=*"
        "atgc"
        "gc_merge"
        "flush_merge"
        "checkpoint_merge"
        "inline_xattr"
        "discard"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXEFI";
      fsType = "vfat";
    };
  };

  # --- Networking & Privacy ---
  networking = {
    hostName = "Portable-NIX";
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      connectionConfig."connection.stable-id" = "\${CONNECTION}/\${BOOT}";
      wifi = {
        scanRandMacAddress = true;
        macAddress = "random";
      };
      ethernet.macAddress = "random";
    };
  };

  # --- ZRAM (RAM Compression) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # --- Hardware & Graphics ---
  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva
        vulkan-loader
        libvdpau-va-gl
      ];
    };
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };

  # --- Services ---
  services = {
    fstrim.enable = true;
    blueman.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    haveged.enable = true;
    thermald.enable = true;
    tlp.enable = false;
    locate.enable = false;

    # Universal Video Drivers
    xserver.videoDrivers = [
      "modesetting"
      "fbdev"
      "vesa"
    ];

    udev.extraRules = ''
      # BFQ for USB/SSD
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*|nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
      # Ghost Mode: Hide internal drives of the host machine
      SUBSYSTEM=="block", ATTRS{removable}=="0", ENV{UDISKS_IGNORE}="1"
    '';
  };

  # --- Security & Systemd ---
  security.tpm2.enable = false;

  systemd = {
    coredump.enable = false;
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;

    # TPM Disable
    tpm2.enable = false;
    units."dev-tpmrm0.device".enable = false;
    services.tailscaled.environment.TS_ENCRYPT_STATE = "false";

    mounts = [
      {
        where = "/var/lib/systemd";
        what = "tmpfs";
        type = "tmpfs";
        options = "mode=0755,size=20M";
      }
    ];
  };

  documentation.enable = false;
  powerManagement.enable = true;
  system.stateVersion = stateVersion;
}

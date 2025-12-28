{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./sync-config.nix
    #./squashfs-store.nix
    ../../common/system.nix
    ../../common/users.nix
  ];

  networking.hostName = "Portable-NIX";

  # --- USB OPTIMIZATIONS ---

  # 1. Aggressive Garbage Collection (Keep only 1-2 generations)
  boot.loader.systemd-boot.configurationLimit = 2; # Current + 1 rollback

  nix.gc = {
    automatic = false;
    dates = "daily";
    options = "--delete-older-than 1d"; # Effectively keeps only the current state
  };

  # 2. Storage Optimization
  nix.settings.auto-optimise-store = true; # Hard-link duplicates

  # 3. Logs to RAM (Prevents constant writing to USB)
  services.journald.extraConfig = "Storage=volatile";

  # 4. Move temporary build files to RAM (Prevents wearing out USB during updates)
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Uses half your RAM for builds

}

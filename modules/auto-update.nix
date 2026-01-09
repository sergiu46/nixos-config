{ ... }:

{
  # Bootloader entry limits
  boot.loader = {
    systemd-boot.configurationLimit = 5;
  };
  # Safe directories for
  nix.settings.safe-directories = [ "/home/sergiu/NixOS" ];

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "NixOS Auto Updater";
        email = "root@localhost";
      };
      safe = {
        directory = "/home/sergiu/NixOS";
      };
    };
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
    randomizedDelaySec = "10min";
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    allowReboot = false;
    dates = "daily";
    enable = true;
    flake = "/home/sergiu/NixOS";
    flags = [
      "--refresh"
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    operation = "boot";
    persistent = true;
    randomizedDelaySec = "10min";
  };

  # Persistent GC timer
  systemd.timers.nix-gc.timerConfig = {
    Persistent = true;
  };
}

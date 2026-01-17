{ ... }:

{

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    flake = "/home/sergiu/NixOS";
    flags = [
      "--refresh"
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
    operation = "boot";
    allowReboot = false;
    randomizedDelaySec = "10min";
  };

  # Automatic garbage collection
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
      persistent = true;
      randomizedDelaySec = "10min";
    };
  };

  # Git settings for auto-updater
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "NixOS Auto Updater";
        email = "root@localhost";
      };
      safe.directory = "/home/sergiu/NixOS";
    };
  };

}

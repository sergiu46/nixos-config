{ userVars, ... }:

{
  # Automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    flake = "/home/${userVars.primaryUser}/${userVars.nixosConfigDir}";
    flags = [
      "--recreate-lock-file"
      "--commit-lock-file"
    ];
    operation = "boot";
    allowReboot = false;
    randomizedDelaySec = "10min";
  };

  # Automatic garbage collection
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 5d";
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
      safe.directory = "/home/${userVars.primaryUser}/${userVars.nixosConfigDir}";
    };
  };
}

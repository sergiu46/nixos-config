{ pkgs, stateVersion, ... }:

{
  imports = [
    ./packages.nix
  ];

  # Audio
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  # Boot kernel packages
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # GNOME desktop
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-calendar
    gnome-contacts
    gnome-maps
    gnome-tour
    totem
    rhythmbox
    geary
    yelp

  ];
  programs.dconf.enable = true;
  programs.dconf.profiles = {
    user = {
      databases = [
        {
          settings = {
            "org/gnome/mutter" = {
              experimental-features = [
                "scale-monitor-framebuffer"
                "variable-refresh-rate"
                "xwayland-native-scaling"
              ];
            };
          };
        }
      ];
    };
  };

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # Local time to match Windows
  time.hardwareClockInLocalTime = true;

  # Networking
  networking.networkmanager.enable = true;

  # Nix settings
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  # Nixpkgs config
  nixpkgs.config.allowUnfree = true;

  # PipeWire audio stack
  services.pipewire = {
    alsa.enable = true;
    alsa.support32Bit = true;
    enable = true;
    jack.enable = false;
    pulse.enable = true;
  };

  # Printing
  services.printing = {
    drivers = [
      pkgs.gutenprint
      pkgs.hplip
    ];
    enable = true;
  };

  # Avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "ro";
    variant = "";
  };

  # Standard NixOS version
  system.stateVersion = stateVersion;

  # Timezone
  time.timeZone = "Europe/Bucharest";
}

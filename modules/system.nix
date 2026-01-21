{ pkgs, stateVersion, ... }:

{
  # Services
  services = {
    # Desktop manager
    desktopManager.gnome.enable = true; # GNOME Desktop
    displayManager.gdm.enable = true; # GDM Display Manager
    gnome.gnome-keyring.enable = true; # GNOME keyring

    # Power management
    power-profiles-daemon.enable = true; # Power profiles for laptops
    thermald.enable = true; # Intel Thermal management
    upower.enable = true; # Power management
    tlp.enable = false; # Disable TLP (conflicts with power-profiles-daemon)

    # Other services
    fstrim.enable = true; # Enable periodic TRIM for SSDs
    blueman.enable = true; # Bluetooth manager
    libinput.enable = true; # Input device management
    geoclue2.enable = true; # Enable location
    localtimed.enable = true; # Set time based on location
  };

  hardware = {
    bluetooth.enable = true; # Enable Bluetooth
    wirelessRegulatoryDatabase = true;
  };

  # Start display manager after
  systemd.services.display-manager = {
    after = [
      "systemd-user-sessions.service"
      "power-profiles-daemon.service"
      "upower.service"
      "bluetooth.service"
      "network-online.target"
    ];
    wants = [
      "power-profiles-daemon.service"
      "upower.service"
      "bluetooth.service"
      "network-online.target"
    ];
  };

  powerManagement.enable = true; # Enable power management

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-calendar
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-tour
    yelp
    showtime
  ];

  # Touchpad Scrooling
  services.udev.extraHwdb = ''
    # Match any device name containing "Alps"
    evdev:name:*Alps*:*
     LIBINPUT_ATTR_RESOLUTION_H=124
     LIBINPUT_ATTR_RESOLUTION_V=124
  '';

  # Mutter experimental features (for better fractional scaling, VRR, etc.)
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
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

  # Session variables for Wayland support
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "xcb"; # Force Qt apps to use X11 backend
    NIXOS_OZONE_WL = "1"; # Enable Ozone/Wayland for Chromium-based browsers
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland for Firefox
    MOZ_DISABLE_RDD_SANDBOX = "1"; # Disable Firefox RDD sandbox for Wayland compatibility
  };

  # Audio (PipeWire modern stack)
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = false;
    pulse.enable = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  # Locale and internationalization
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

  # Timezone and hardware clock (to match dual-boot Windows)
  time = {
    hardwareClockInLocalTime = true;
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "ro";
    variant = "";
  };

  # Printing and driver support
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };

  # Network discovery (mDNS for local services/printers)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Nix settings
  nix.settings = {
    download-buffer-size = 500000000; # ~500MB
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = stateVersion;
}

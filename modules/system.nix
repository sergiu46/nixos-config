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
      "dbus.service"
    ];
    wants = [
      "power-profiles-daemon.service"
      "upower.service"
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
    evdev:name:*ALPS*TouchPad*:*
      # 40 is twice the real resolution (slower)
      # 80 is four times the real resolution (very slow)
      EVDEV_ABS_00=713:2614:160
      EVDEV_ABS_01=90:1165:166
      EVDEV_ABS_35=713:2614:160
      EVDEV_ABS_36=90:1165:166
  '';

  # dconf
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          # Display & Performance Features
          "org/gnome/mutter" = {
            experimental-features = [
              "xwayland-native-scaling"
              "scale-monitor-framebuffer"
              "variable-refresh-rate"
            ];
          };
          # auto timezone
          "org/gnome/desktop/datetime" = {
            automatic-timezone = true;
          };
          "org/gnome/system/location" = {
            enabled = true;
          };
        };
      }
    ];
  };

  # Session variables for Wayland support
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORMTHEME = "gnome";
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
    QT_WAYLAND_FORCE_DPI = "96";
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland for Firefox
    MOZ_CRASHREPORTER_DISABLE = "1"; # Disable crash reports
  };

  # Apps need these 'engines' installed to render the themes correctly
  environment.systemPackages = with pkgs; [
    adwaita-qt # Qt engine for Adwaita style
    adwaita-qt6 # Qt6 version
    qgnomeplatform # Platform support for Qt in GNOME
    qgnomeplatform-qt6
    libsForQt5.qt5.qtwayland # Wayland libraries for Qt5
    kdePackages.qtwayland # Wayland libraries for Qt6
    adwaita-icon-theme
    glib
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
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
    timeZone = "Europe/Bucharest";
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
    auto-optimise-store = true;
    download-buffer-size = 500000000;
    http-connections = 50;
    max-substitution-jobs = 30;
    stalled-download-timeout = 60;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  boot.loader.systemd-boot.configurationLimit = 30;
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = stateVersion;
}

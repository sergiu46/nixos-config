{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.forge
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.dash-to-panel
    # Libre office
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ro_RO
    # Unstable packages
    unstable.nextcloud-client
  ];

  fonts.packages = with pkgs; [
    corefonts # Microsoft's TrueType core fonts
    vista-fonts # Includes Calibri, Cambria, etc.
    google-fonts # Good for general compatibility
    symbola # A massive font for symbols and boxes
    freefont_ttf # Includes many standard symbols
    liberation_ttf # Excellent metric-compatible replacement for MS fonts
  ];
  fonts.fontconfig.allowBitmaps = false;

}

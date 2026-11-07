{ ... }:

{
  # Flatpak
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];

    packages = [
    ];

    overrides.settings = {
      global = {
        # Grant universal access to GPU rendering nodes and hardware acceleration
        Context.devices = [ "dri" ];
        # Grant display server access for both Wayland and X11 sessions
        Context.sockets = [
          "wayland"
          "fallback-x11"
          "x11"
        ];
      };
    };
  };

}

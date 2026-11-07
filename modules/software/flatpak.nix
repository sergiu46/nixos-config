{ ... }:

{
  # Flatpak configuration
  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    remotes = [
      {
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        name = "flathub";
      }
    ];

    overrides.settings = {
      global = {
        Context.devices = [ "dri" ];
        Context.sockets = [
          "wayland"
          "fallback-x11"
          "x11"
        ];

        # Mount host hardware driver paths inside the sandbox
        Context.filesystems = [
          "/run/current-system/sw/lib/dri:ro"
          "/run/opengl-driver/lib:ro"
        ];

        Environment = {
          LIBVA_DRIVERS_PATH = "/run/current-system/sw/lib/dri";
        };
      };
    };
  };
}

{ ... }:

{
  # Firefox with configs
  programs.firefox = {
    enable = true;
    preferences = {
      # Basic Cleanups
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.skipDefaultBrowserCheckOnFirstRun" = true;

      # Core Acceleration (Safe for all modern GPUs)
      "media.ffmpeg.vaapi.enabled" = true;
      "gfx.webrender.all" = true;
      "gfx.webrender.compositor" = true;
      "media.rdd-ffmpeg.enabled" = true;

      # Modern Wayland / HiDPI Scaling Support
      "widget.wayland-dmabuf-vaapi.enabled" = true;
      "widget.wayland.fractional-scale-factor.enabled" = true;
    };
  };

  # Variables for firefox
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_CRASHREPORTER_DISABLE = "1"; # Disable crash reports
  };

}

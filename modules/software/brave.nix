{ pkgs, ... }:

{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    brave
  ];

  # Brave options
  nixpkgs.overlays = [
    (final: prev: {
      brave = prev.brave.override {
        commandLineArgs = [
          "--restore-last-session"
          "--hide-crash-restore-bubble"
          "--ozone-platform=wayland"
          "--disable-features=WaylandFractionalScaleV1"
          "--disk-cache-dir=/tmp/brave-cache"
          "--disable-gpu-shader-disk-cache"
        ];
      };
    })
  ];

}

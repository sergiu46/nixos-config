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
          "--disable-gpu-shader-disk-cache"
        ];
      };
    })
  ];

}

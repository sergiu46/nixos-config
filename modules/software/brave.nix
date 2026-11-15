{ pkgs, lib, ... }:

let
  braveFlags = [
    "--restore-last-session"
    "--hide-crash-restore-bubble"
    "--ozone-platform=wayland"
    "--disable-smooth-scrolling"
    "--disable-gpu-shader-disk-cache"
    "--disable-features=WaylandFractionalScaleV1,OutdatedBuildDetector,UseChromeOSDirectVideoDecoder"
  ];
in
{
  environment.systemPackages = [
    (pkgs.unstable.brave.override {
      commandLineArgs = lib.concatStringsSep " " braveFlags;
    })
  ];
}

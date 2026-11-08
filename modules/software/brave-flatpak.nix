{ pkgs, ... }:

let
  braveFlags = pkgs.writeText "brave-flags.conf" ''
    --enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiIgnoreDriverChecks
    --disable-features=WaylandFractionalScaleV1
    --ignore-gpu-blocklist
    --ozone-platform-hint=auto
    --restore-last-session
    --hide-crash-restore-bubble
    --disable-gpu-shader-disk-cache
  '';
in
{
  services.flatpak.packages = [
    {
      appId = "com.brave.Browser";
      origin = "flathub";
    }
  ];

  # Provision Brave's flags file for every user with a home directory
  system.activationScripts.braveFlatpakFlags = ''
    for home in /home/*; do
      [ -d "$home" ] || continue
      owner="$(stat -c '%U' "$home")"
      group="$(stat -c '%G' "$home")"
      dir="$home/.var/app/com.brave.Browser/config"
      install -d "$dir"
      install -m 644 ${braveFlags} "$dir/brave-flags.conf"
      chown -R "$owner:$group" "$home/.var"
    done
  '';
}

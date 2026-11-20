{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;

    # Libraries made available to foreign (non-Nix) binaries.
    libraries = with pkgs; [
      # C/C++ runtime and common basics
      stdenv.cc.cc.lib
      zlib
      openssl
      glib
      curl
      expat
      libuuid

      # Graphics / GUI
      libGL
      libGLU
      freetype
      fontconfig
      libxkbcommon
      gtk3
      cairo
      pango
      gdk-pixbuf
      atk
      dbus

      # X11
      libx11
      libxext
      libxcursor
      libxrandr
      libxinerama
      libxi
      libxrender
      libxcb

      # Wayland
      wayland

      # Audio
      alsa-lib
      libpulseaudio
    ];
  };
}

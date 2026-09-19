{ config, pkgs, ... }:

let
  user = config.home.username;
in
{
  # Home packages
  home.packages = with pkgs; [
    nixd # The actual server
    nixfmt # Formatter
  ];

  # VSCodium
  programs.vscodium = {
    enable = true;
    mutableExtensionsDir = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };

  # Writable symlink to your repo
  xdg.configFile."VSCodium/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/users/${user}/vscode-settings.json";
}

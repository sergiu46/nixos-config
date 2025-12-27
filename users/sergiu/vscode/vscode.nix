{ config, pkgs, ... }:

let
  user = config.home.username;
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };

  # Writable symlink to your repo
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/users/${user}/vscode/vscode-settings.json";

  home.packages = with pkgs; [
    nixd # The actual server
    nixfmt-rfc-style # Formatter
  ];
}

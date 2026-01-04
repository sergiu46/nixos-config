{ config, pkgs, ... }:

let
  user = config.home.username;
in
{
  # Home packages
  home.packages = with pkgs; [
    nixd # The actual server
    nixfmt-rfc-style # Formatter
  ];

  # VSCode
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    package = pkgs.vscode;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };

  # Writable symlink to your repo
  xdg.configFile."Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/${user}/NixOS/users/${user}/vscode-settings.json";
}

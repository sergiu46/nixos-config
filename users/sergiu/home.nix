{ pkgs, ... }: {
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";

  home.packages = with pkgs; [
    # unstable.vscode # Unstable version
    unstable.bitwarden-desktop
    gnomeExtensions.just-perfection
    gnomeExtensions.system-monitor
    gnomeExtensions.dash-to-dock
  ];

  # vscode
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
      ];
    };
  };

  home.shellAliases = {

    switch = "sudo nixos-rebuild switch --flake ~/NixOS#Latitude-NIX";
    check = "nixos-rebuild build --flake ~/NixOS#Latitude-NIX";
    upswitch = "pushd ~/NixOS && nix flake update && git add flake.lock && sudo nixos-rebuild switch --flake .#Latitude-NIX && popd";
  };


  programs.bash.enable = true;
  home.stateVersion = "25.11";
}

{ pkgs, ... }:
{
  home.username = "sergiu";
  home.homeDirectory = "/home/sergiu";

  home.packages = with pkgs; [
    # unstable.vscode # Unstable version
    unstable.bitwarden-desktop
    gnomeExtensions.just-perfection
    gnomeExtensions.system-monitor
    gnomeExtensions.dash-to-dock

    nixd
    nixfmt-rfc-style
    alejandra
  ];

  # vscode
  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
      ];

      # This writes ~/.config/Code/User/settings.json
      userSettings = {
        "nix.serverPath" = "nixd";
        "nix.enableLanguageServer" = true;

        "nix.serverSettings" = {
          "nixd" = {
            formatting = {
              command = [ "nixfmt" ];
            };

            # OPTIONAL: enable flake-aware option completion
            # Update these paths to match your flake
            options = {
              nixos = {
                expr = "(builtins.getFlake \"/home/sergiu/NixOS\").nixosConfigurations.myhostname.options";
              };
              home_manager = {
                expr = "(builtins.getFlake \"/home/sergiu/NixOS\").homeConfigurations.sergiu.options";
              };
            };
          };
        };

        "editor.formatOnSave" = true;
      };
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

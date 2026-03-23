{ pkgs, ... }:
{
  # Enable nix-ld for binary compatibility
  programs.nix-ld.enable = true;

  # Bottles is best installed via Flatpak or environment.systemPackages
  environment.systemPackages = with pkgs; [
    bottles
  ];
}

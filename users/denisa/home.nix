{ stateVersion, ... }:
{
  home.username = "denisa";
  home.homeDirectory = "/home/denisa";
  home.stateVersion = stateVersion;
  programs.bash.enable = true;
}

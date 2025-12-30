{ ... }:
{
  users.users.sergiu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    home = "/home/sergiu";
    initialHashedPassword = "$6$l8tR42rMgdMGk/MO$lzJjl07et688Xo/sPlOtm7yHNakS.uWg5Tkwc0VHAI.grz6A7VhcFhI5./g.LF8SFEka4YHxuQUKAOvgSjHW2/";

  };

  users.users.denisa = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    home = "/home/denisa";
    initialHashedPassword = "$6$l8tR42rMgdMGk/MO$lzJjl07et688Xo/sPlOtm7yHNakS.uWg5Tkwc0VHAI.grz6A7VhcFhI5./g.LF8SFEka4YHxuQUKAOvgSjHW2/";
  };
}

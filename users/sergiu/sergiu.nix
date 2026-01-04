{ ... }:
{
  users.users.root = {
    initialHashedPassword = "$6$.6Pbi5WVg1gulXos$AD.yjVoVfyT6WXzP5qupUfGA.UJJmjAaW2xMbAc.q9lxdGK3Zsz/C48T.jtug/y3EGeOQ5ilksmA0oWoymz8i1";
  };

  users.users.sergiu = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    home = "/home/sergiu";
    initialHashedPassword = "$6$VyhlVTPZi8mOrqpI$c7n6J.M58wpMEapNZ8hkUMK0tF.3p4vEaAZLuw1.ZTkRys7brvjCvK8xxQ6.FVEs4GEiy64e7Pb.rNdt3EUjd0";
  };
  home-manager.users.sergiu = import ./home.nix;
}

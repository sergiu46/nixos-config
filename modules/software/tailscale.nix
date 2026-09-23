{ pkgs, ... }:

{

  # Gui for tailscale
  environment.systemPackages = with pkgs; [
    trayscale
  ];

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}

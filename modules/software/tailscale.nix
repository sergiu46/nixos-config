{ pkgs, ... }:

{

  # Gui for tailscale
  environment.systemPackages = with pkgs; [
    unstable.trayscale
  ];

  # Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };

}

{ lib, configName, ... }:

{
  # Networking & Privacy (Physical / Portable)
  networking = {
    hostName = configName;
    useDHCP = lib.mkDefault true;
    usePredictableInterfaceNames = false;
    networkmanager = {
      enable = true;
      settings = {
        connectivity = {
          uri = "http://nmcheck.gnome.org/check_network_status.txt";
          response = "NetworkManager is online";
          interval = 300;
        };
      };
      connectionConfig."connection.stable-id" = "\${CONNECTION}";
      wifi = {
        scanRandMacAddress = true;
        macAddress = "stable";
      };
      ethernet.macAddress = "stable";
    };
  };

  # Network discovery (mDNS / DNS-SD / Zeroconf)
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables resolving .local hostnames via NSS
    openFirewall = true; # Opens UDP port 5353 in the firewall

    # Broadcast this machine on the network so other devices can discover it
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

}

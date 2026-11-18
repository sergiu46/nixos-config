{ pkgs, ... }:

let
  chain = "cast-allow";
  ipt = "${pkgs.iptables}/bin/iptables";
  ports = "32768:60999"; # Linux ephemeral range

  watcher = pkgs.writeShellScript "chromecast-fw" ''
    ${ipt} -N ${chain} 2>/dev/null || true
    ${ipt} -F ${chain}

    declare -A seen
    ${pkgs.avahi}/bin/avahi-browse -rp _googlecast._tcp | \
    while IFS=';' read -r ev iface proto name type domain host addr port txt; do
      [ "$proto" = IPv4 ] || continue
      case "$ev" in
        '=')
          seen[$name]=$addr
          ${ipt} -C ${chain} -s "$addr" -p tcp --dport ${ports} -j nixos-fw-accept 2>/dev/null \
            || ${ipt} -A ${chain} -s "$addr" -p tcp --dport ${ports} -j nixos-fw-accept
          ;;
        '-')
          old=''${seen[$name]:-}
          [ -n "$old" ] && ${ipt} -D ${chain} -s "$old" -p tcp --dport ${ports} -j nixos-fw-accept 2>/dev/null
          unset "seen[$name]"
          ;;
      esac
    done
  '';
in
{
  environment.systemPackages = [ pkgs.gnome-network-displays ];

  networking.firewall = {
    # Miracast
    allowedTCPPorts = [
      7236
      7250
    ];
    allowedUDPPorts = [
      7236
      5353
    ];

    trustedInterfaces = [ "p2p-wlan0-0" ];

    extraCommands = ''
      iptables -A nixos-fw -i p2p-+ -j nixos-fw-accept

      # Chromecast: dynamic rules are managed by chromecast-fw.service
      ${ipt} -N ${chain} 2>/dev/null || true
      ${ipt} -A nixos-fw -j ${chain}
    '';
  };

  systemd.services.chromecast-fw = {
    description = "Allow discovered Chromecasts through the firewall";
    wantedBy = [ "multi-user.target" ];
    after = [
      "firewall.service"
      "avahi-daemon.service"
    ];
    requires = [ "avahi-daemon.service" ];
    partOf = [ "firewall.service" ];
    serviceConfig = {
      ExecStart = watcher;
      Restart = "on-failure";
    };
  };
}

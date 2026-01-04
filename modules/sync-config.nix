{ pkgs, ... }:

{
  # Download git config at startup
  systemd.services.sync-nixos-config = {
    description = "Sync NixOS config from GitHub on boot";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "sergiu";
      RemainAfterExit = true;
    };
    script = ''
      CONFIG_DIR="/home/sergiu/NixOS"
      REPO_URL="https://github.com/sergiu46/nixos-config.git"

      for i in {1..60}; do
        if ${pkgs.curl}/bin/curl -s --head  --request GET http://google.com | grep "200 OK" > /dev/null; then
          break
        fi
        sleep 1
      done

      if [ ! -d "$CONFIG_DIR" ]; then
        ${pkgs.git}/bin/git clone $REPO_URL $CONFIG_DIR
      else
        cd $CONFIG_DIR
        ${pkgs.git}/bin/git fetch origin
        ${pkgs.git}/bin/git reset --hard origin/main
      fi
    '';
  };

}

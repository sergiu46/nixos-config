{ pkgs, ... }:

{
  systemd.user.services.sync-nixos-config = {
    description = "Sync NixOS config from GitHub after login";
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "300s";
    };

    path = with pkgs; [
      git
      curl
      coreutils
      gnugrep
    ];

    script = ''
      CONFIG_DIR="$HOME/NixOS"
      HTTPS_URL="https://github.com/sergiu46/nixos-config.git"
      SSH_URL="git@github.com:sergiu46/nixos-config.git"

      echo "Waiting for internet connection..."
      CONNECTED=false
      for i in {1..150}; do
        if curl -s --connect-timeout 3 --head https://github.com > /dev/null; then
          echo "Internet is up!"
          CONNECTED=true
          break
        fi
        sleep 2
      done

      if [ "$CONNECTED" = false ]; then
        echo "Network timeout. Exit."
        exit 1
      fi

      if [ ! -d "$CONFIG_DIR" ]; then
        echo "Cloning repository..."
        git clone "$HTTPS_URL" "$CONFIG_DIR"
        cd "$CONFIG_DIR"
        git remote set-url --push origin "$SSH_URL"
      else
        echo "Updating repository..."
        cd "$CONFIG_DIR"
        
        # Public HTTPS for fetching (no Bitwarden needed), SSH for pushing
        git remote set-url origin "$HTTPS_URL"
        git remote set-url --push origin "$SSH_URL"

        git fetch origin
        git reset --hard origin/main
      fi
    '';
  };
}

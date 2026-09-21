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
      REPO_URL="https://github.com/sergiu46/nixos-config.git"

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
        git clone "$REPO_URL" "$CONFIG_DIR"
      else
        echo "Updating repository..."
        cd "$CONFIG_DIR"
        
        git remote set-url origin "$REPO_URL"
        git fetch origin
        git reset --hard origin/main
      fi
    '';
  };
}

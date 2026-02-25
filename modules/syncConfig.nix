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
      openssh # Added to ensure ssh tools are available
    ];

    script = ''
      CONFIG_DIR="$HOME/NixOS"
      # CHANGED: Using the SSH URL
      REPO_URL="git@github.com:sergiu46/nixos-config.git"

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
        echo "Network timeout. Could not sync config."
        exit 1
      fi

      if [ ! -d "$CONFIG_DIR" ]; then
        echo "Cloning repository via SSH..."
        git clone $REPO_URL "$CONFIG_DIR"
      else
        echo "Updating repository..."
        cd "$CONFIG_DIR"
        
        # SELF-HEALING: If the remote is HTTPS, switch it to SSH
        CURRENT_URL=$(git remote get-url origin)
        if [[ "$CURRENT_URL" == "https://"* ]]; then
          echo "Switching remote from HTTPS to SSH..."
          git remote set-url origin $REPO_URL
        fi

        git fetch origin
        git reset --hard origin/main
      fi
    '';
  };
}

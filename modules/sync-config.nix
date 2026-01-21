{ pkgs, ... }:

{
  systemd.user.services.sync-nixos-config = {
    description = "Sync NixOS config from GitHub after login";

    # This ensures it starts once your desktop session is active
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      # If the script fails (e.g., GitHub is down), it will try again in 5 minutes
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

      # 1. Improved Network Wait Loop
      # We check every 2 seconds for a max of 5 minutes (150 attempts)
      # This is perfect for slow Wi-Fi or public hotspots on a USB build.
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

      # 2. Sync Logic
      if [ ! -d "$CONFIG_DIR" ]; then
        echo "Cloning repository..."
        git clone $REPO_URL "$CONFIG_DIR"
      else
        echo "Updating repository..."
        cd "$CONFIG_DIR"
        git fetch origin
        git reset --hard origin/main
      fi
    '';
  };
}

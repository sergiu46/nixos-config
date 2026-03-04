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
      openssh
    ];

    script = ''
      CONFIG_DIR="$HOME/NixOS"
      REPO_URL="git@github.com:sergiu46/nixos-config.git"
      export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
      export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

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

      echo "Waiting for Bitwarden SSH keys to be available..."
      KEYS_AVAILABLE=false
      for i in {1..60}; do
        if [ -S "$SSH_AUTH_SOCK" ] && ssh-add -l > /dev/null 2>&1; then
          echo "Bitwarden agent is ready and has keys!"
          KEYS_AVAILABLE=true
          break
        fi
        sleep 2
      done

      if [ "$KEYS_AVAILABLE" = false ]; then
        echo "Error: Bitwarden agent not found or no keys loaded. Is Bitwarden unlocked?"
        exit 1
      fi

      if [ ! -d "$CONFIG_DIR" ]; then
        echo "Cloning repository..."
        git clone "$REPO_URL" "$CONFIG_DIR"
      else
        echo "Updating repository..."
        cd "$CONFIG_DIR"
        
        CURRENT_URL=$(git remote get-url origin)
        if [[ "$CURRENT_URL" == "https://"* ]]; then
          git remote set-url origin "$REPO_URL"
        fi

        git fetch origin
        git reset --hard origin/main
      fi
    '';
  };
}

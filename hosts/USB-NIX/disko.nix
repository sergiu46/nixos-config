{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        # This name "main" will be used in the install command
        type = "disk";
        # For USB installs, leave device blank or use a placeholder – disko-install handles it dynamically
        # device = "/dev/sda";  # Optional; better to pass via --disk
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4"; # Or "btrfs", "xfs", etc.
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

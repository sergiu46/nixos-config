{ ... }:

{
  # zramSwap configuration
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 80;
    priority = 100;
  };

  # Advanced Kernel Tweaks for zram efficiency
  boot.kernel.sysctl = {
    "vm.page-cluster" = 0; # Don't pre-fetch; handles one page at a time
    "vm.watermark_boost_factor" = 0; # Prevents unnecessary swap-ins (reduces lag)
    "vm.watermark_scale_factor" = 125; # Keeps a larger "free RAM" buffer for spikes
  };
}

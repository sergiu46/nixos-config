{ ... }:

{
  # Disable TPM at the Kernel Level
  boot.blacklistedKernelModules = [
    "tpm"
    "tpm_tis"
    "tpm_tis_core"
    "tpm_crb"
  ];

  # Disable TPM in early boot (Initrd)
  boot.initrd.systemd.tpm2.enable = false;

  # Disable TPM in Security & Systemd
  security.tpm2.enable = false;
  systemd = {
    tpm2.enable = false;
    units."dev-tpmrm0.device".enable = false;
  };

  # Disable TPM for tailscale
  services.tailscaled.environment.TS_ENCRYPT_STATE = "false";

}

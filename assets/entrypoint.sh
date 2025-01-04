#!/bin/bash
set -e

echo "[INFO]: validating Proxmox Answer File stored at /installer/answer.toml"
proxmox-auto-install-assistant validate-answer /installer/answer.toml

echo "[INFO]: check for Proxmox VE ISO at mounted directory /installer/iso"
set +e
ISO_FILE=$(ls /installer/iso/proxmox-ve*.iso 2>/dev/null | grep -v "auto-from-iso")
set -e

if [ -z "$ISO_FILE" ]; then
  echo "[WARN]: No ISO found. Downloading latest Proxmox VE ISO now."
  bash ./download-helper.sh
  ISO_FILE=$(ls /installer/iso/proxmox-ve*.iso 2>/dev/null | grep -v "auto-from-iso")
else
  echo "[INFO]: Found Proxmox VE ISO: $ISO_FILE"
fi

echo "[INFO]: preparing Proxmox VE ISO mounted at /installer/proxmox-ve*.iso"
proxmox-auto-install-assistant prepare-iso $ISO_FILE --fetch-from iso --answer-file answer.toml

echo "[INFO]: generating additional Proxmox VE auto installer ISO that allows installation on eMMC"
bash ./patch-emmc.sh

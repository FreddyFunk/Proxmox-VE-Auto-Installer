#!/bin/bash
set -e

# Set the URL of the Proxmox ISO page
URL="https://enterprise.proxmox.com/iso/"

# Fetch the HTML content of the page
HTML_CONTENT=$(curl -s $URL)

# Extract the latest Proxmox VE ISO download link
ISO_URL=$(echo "$HTML_CONTENT" | grep -oP '(?<=href=")[^"]*proxmox-ve_[^"]*\.iso' | sort -V | tail -1)

# Check if the ISO URL was found
if [ -z "$ISO_URL" ]; then
  echo "No Proxmox VE ISO found at $URL."
  exit 1
fi

# Complete the URL if it is relative
if [[ $ISO_URL != http* ]]; then
  ISO_URL="${URL%/}/$ISO_URL"
fi

# Download the latest ISO
echo "Downloading the latest Proxmox VE ISO from $ISO_URL..."
curl -O $ISO_URL

# Confirm the download
if [ $? -eq 0 ]; then
  echo "Download completed successfully."
else
  echo "Failed to download the ISO."
  exit 1
fi

# Download the checksum file
CHECKSUM_FILE="SHA256SUMS"
CHECKSUM_URL="${URL}${CHECKSUM_FILE}"
echo "Downloading checksum file from $CHECKSUM_URL..."
curl -O $CHECKSUM_URL

# Confirm the download of the checksum file
if [ $? -eq 0 ]; then
  echo "Checksum file downloaded successfully."
else
  echo "Failed to download the checksum file."
  exit 1
fi

# Extract the correct checksum for the downloaded ISO
ISO_NAME=$(basename $ISO_URL)
CHECKSUM=$(grep $ISO_NAME $CHECKSUM_FILE | awk '{print $1}')

# Validate the checksum
echo "Validating the checksum..."
echo "$CHECKSUM  $ISO_NAME" | sha256sum -c -

# Confirm the checksum validation
if [ $? -eq 0 ]; then
  echo "Checksum validation completed successfully."
  mv *.iso /installer/iso/
else
  echo "Checksum validation failed."
  exit 1
fi

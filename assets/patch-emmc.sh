#!/bin/bash
set -e

# followed example for updating files in ISO with xorriso from:
# https://wiki.debian.org/RepackBootableISO#In_xorriso_load_ISO_tree_and_write_modified_new_ISO

# Variables
ISO_FILE=$(ls /installer/iso/*auto-from-iso.iso 2> /dev/null | head -n 1)
NEW_ISO_FILE="${ISO_FILE%.iso}-patch-emmc.iso"
SQUASH_FS="pve-installer.squashfs"
SQUASH_FS_PATCHED="pve-installer-patched.squashfs"
FILE="Block.pm"
DIRECTORY="/usr/share/perl5/Proxmox/Sys"
FILE_PATH="$DIRECTORY/$FILE"

echo "[INFO]: Get the $SQUASH_FS file from the original ISO"
xorriso -osirrox on -indev "$ISO_FILE" -extract $SQUASH_FS "./$SQUASH_FS"

echo "[INFO]: Extract $SQUASH_FS"
unsquashfs -d pve-installer-patched $SQUASH_FS

echo "[INFO]: Apply patch to allow eMMC disks in $FILE_PATH"
OLD_STRING='    } elsif ($dev =~ m|^/dev/nvme\d+n\d+$|) {
	return "${dev}p$partnum";'

NEW_STRING='    } elsif ($dev =~ m|^/dev/nvme\d+n\d+$|) {
	return "${dev}p$partnum";
    } elsif ($dev =~ m|^/dev/mmcblk\d+$|) {
	return "${dev}p$partnum";'

OLD_FILE_CONTENTS=$(< pve-installer-patched/$FILE_PATH)
NEW_FILE_CONTENTS=${OLD_FILE_CONTENTS//"$OLD_STRING"/"$NEW_STRING"}

printf '%s\n' "$NEW_FILE_CONTENTS" > pve-installer-patched/$FILE_PATH

echo "[DEBUG]: Print content of patched file pve-installer-patched/$FILE_PATH"
cat pve-installer-patched/$FILE_PATH

echo "[INFO]: Create $SQUASH_FS"
mksquashfs pve-installer-patched $SQUASH_FS_PATCHED

echo "[INFO]: If present: Remove an older version of $NEW_ISO_FILE"
test -e "$NEW_ISO_FILE" && rm "$NEW_ISO_FILE"

echo "[INFO]: Make $NEW_ISO_FILE from $ISO_FILE and the changed files"
xorriso \
   -indev "$ISO_FILE" \
   -outdev "$NEW_ISO_FILE" \
   \
   -map "./$SQUASH_FS_PATCHED" $SQUASH_FS \
   \
   -boot_image any replay \
   \
   -compliance no_emul_toc \
   -padding included

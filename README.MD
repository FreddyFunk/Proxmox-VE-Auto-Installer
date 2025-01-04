# Proxmox VE Auto Installer ISO Generator

This project provides a simple script that generates a Proxmox VE automatic installer ISO file described at [Automated Installation](https://pve.proxmox.com/wiki/Automated_Installation) and [Install Proxmox VE](https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_12_Bookworm#Install_a_standard_Debian_Bookworm_(amd64)) of the official Proxmox Wiki. This script utilizes containers as build environments so it does not bloat your system with packages and can be run everywhere, as well as in CI pipelines.

## Configuration

This repository contains a [default configuration](assets/answer.toml). You can provide a custom configuration file in a valid [Answer File Format](https://pve.proxmox.com/wiki/Automated_Installation#Answer_File_Format_2). If you want to overwrite the default configuration, you need to mount your Answer File at `/installer/answer.toml` when running the conainer.

## Building the container for generating the ISO

```bash
docker build -t proxmox-auto .
```

## Run

Place your Proxmox VE ISO in your current working directory or let the auto downloader download the latest version of Proxmox VE.

The container needs to be run with elevated permissions to extract pve-installer.squashfs and patch the installer to allow installation on eMMC drives.

```bash
# default configuration
docker run -v $(pwd):/installer/iso --privileged proxmox-auto
# custom configuration
docker run -v $(pwd):/installer/iso -v /installer/answer.toml:/path/to/custom/answer --privileged proxmox-auto
```

## eMMC Installation Patch

Proxmox does not allow installation on eMMC disks by default due to performance and reliablity reasons, but some single board computers (SBCs) ship with eMMC storage that would be sufficient for most educationital and home use. Some popular options are the ZimaBoard and ZimaBlade by IceWhale Technology.

This project provides an easy way to build a patched Proxmox VE auto installer ISO that allows the installation on eMMC storage. Recommended `disk-setup` settings to the [Answer File](assets/answer.toml) are:

### Zimablade & Zimaboard:

```toml
[disk-setup]
filesystem = "zfs"
zfs.raid = "raid1"
disk_list = ["mmcblk0"]
```

## Disclaimer

This is an **unofficial** project for educational purposes. This project is not affiliated with or endorsed by Proxmox and Proxmox Server Solutions GmbH.

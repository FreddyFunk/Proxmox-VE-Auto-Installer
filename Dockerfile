FROM debian:bookworm
# install wget for downloading gpg key for Proxmox VE repository
RUN apt update && apt install -y wget
# add Proxmox VE repository and verified repository key
RUN echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list && \
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    echo "7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87 /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg" > /tmp/proxmox-checksum && \
    sha512sum -c /tmp/proxmox-checksum && rm /tmp/proxmox-checksum
# install Proxmox tools
RUN apt update && apt full-upgrade -y
RUN apt install -y proxmox-auto-install-assistant xorriso curl squashfs-tools 
WORKDIR /installer
COPY assets/ .

ENTRYPOINT ["./entrypoint.sh"]
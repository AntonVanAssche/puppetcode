# Puppetcode

This is a personal homelab project utilizing two Raspberry Pi 4B devices (
Homer and Marge), both running Debian Bullseye. The infrastructure is mostly
managed with Puppet, automating the setup and configuration of services.

## Key Features

- **Homer**: A media streaming and monitoring server with Emby, Transmission
  for torrenting, and Grafana for performance monitoring using Prometheus
  and Node Exporter.
- **Marge**: A Network-Attached Storage (NAS) solution with Samba for file
  sharing, Pihole + Unbound for ad-blocking, and Tailscale for secure remote
  access.
  - **RAID 5 Array**: Powered by four SATA HDDs, managed via a Raxda Rock Pi
    SATA HAT.

### RAID 5 Array Setup (Marge)

#### 1. **Create a New RAID 5 Array**

```console
# mdadm --create --verbose /dev/md0 \
    --level=5 \
    --raid-devices=4 \
    /dev/sda /dev/sdb /dev/sdc /dev/sdd
# watch cat /proc/mdstat
# mkfs.ext4 /dev/md0
# mdadm --detail /dev/md0
```

#### 2. **Assemble an Existing RAID 5 Array**

```console
# mdadm --assemble --scan --verbose
# mdadm --detail --scan | tee /etc/mdadm.conf
# update-initramfs -u
# mdadm --detail /dev/md0
```

## Installation & Setup

> :warning: Do not apply this code without understanding what it does. It is
> intended for personal use and may not be suitable for your environment.

```console
# wget https://raw.githubusercontent.com/AntonVanAssche/puppetcode/refs/heads/master/bin/puppetcode.sh
# chmod +x puppetcode.sh
# ./puppetcode.sh -i
```

This will install Puppet, necessary dependencies, and the deb package of this repo.

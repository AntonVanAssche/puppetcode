# Puppetcode

Personal homelab infrastructure managed with OpenVox.

The repository contains the Puppet/OpenVox code, configuration files, scripts, and Debian packaging used to configure my two Raspberry Pi 4B servers:

- **Homer**: media and monitoring server
- **Marge**: NAS and network services

The main entrypoint is `puppetcode.sh`:

```console
$ puppetcode.sh -h
Usage: puppetcode.sh [OPTIONS]

OPTIONS:
    -a  Apply the Puppet manifest.
    -d  Disable the Puppet code systemd timer
    -e  Enable the Puppet code systemd timer
    -h  Show this help message.
    -i  Install the Puppet code and dependencies.
    -m  Install the Puppet modules using r10k.
    -u  Upgrade the Puppet code.
```

## Setup

```console
# wget https://raw.githubusercontent.com/AntonVanAssche/puppetcode/refs/heads/master/bin/puppetcode.sh
# chmod +x puppetcode.sh
# ./puppetcode.sh -i
```

### RAID 5 Array Setup (Marge)

#### Create a New RAID 5 Array

```console
# mdadm --create --verbose /dev/md0 \
    --level=5 \
    --raid-devices=4 \
    /dev/sda /dev/sdb /dev/sdc /dev/sdd
# watch cat /proc/mdstat
# mkfs.ext4 /dev/md0
# mdadm --detail /dev/md0
```

#### Assemble an Existing RAID 5 Array

```console
# mdadm --assemble --scan --verbose
# mdadm --detail --scan | tee /etc/mdadm/mdadm.conf
# update-initramfs -u
# mdadm --detail /dev/md0
```

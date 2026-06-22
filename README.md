# vagrant-raid-mdadm
This project provisions a virtual machine using Vagrant and VirtualBox to practice software RAID configuration with `mdadm`.

## Overview

- Base OS: CentOS Stream 10
- RAID type: RAID10 (mdadm)
- Virtual disks: 6 × 512MB
- Filesystem: ext4
- Partitions: 5 logical partitions on RAID array
- Auto-provisioned via shell script

## VM Configuration

- CPU: 1 core
- RAM: 2 GB
- Network: Private (192.168.56.10)
- Storage: SATA controller with dynamically created VDI disks

## Provisioning

On first boot, the following are automatically configured:

1. Install required packages:
   - mdadm
   - parted
   - smartmontools, hdparm, gdisk

2. Create RAID10 array:
   - Device: `/dev/md10`
   - Disks: `/dev/sd[b-g]`

3. Partitioning:
   - GPT table
   - 5 equal partitions

4. Filesystems:
   - ext4 formatted partitions
   - Mounted under `/raid/part1` … `/raid/part5`

5. Persistence:
   - RAID auto-assembly via `/etc/mdadm.conf`
   - Mounts added to `/etc/fstab`

## Usage

```bash
vagrant up
vagrant ssh

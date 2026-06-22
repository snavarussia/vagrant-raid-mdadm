#!/bin/bash
set -euo pipefail

# Ensure script is run as root
[[ $EUID -eq 0 ]] || {
  echo "Run as root"
  exit 1
}

# Install required package for RAID management
install_mdadm() {
  dnf -y install mdadm parted
}

# Create RAID10 array using 6 disks
create_raid() {
  # IMPORTANT: --force ensures creation in automated environment
  mdadm --create /dev/md10 \
    --level=10 \
    --raid-devices=6 \
    --force \
    /dev/sd[b-g]

  # Wait for udev to create device nodes
  udevadm settle
}

# Show RAID status
check_raid() {
  cat /proc/mdstat
  mdadm --detail /dev/md10
  lsblk
}

# Save RAID configuration for automatic assembly at boot
save_raid() {
  # Store RAID metadata
  mdadm --detail --scan > /etc/mdadm.conf

  # Rebuild initramfs using dracut
  dracut --regenerate-all --force
}

# Create partitions on RAID device and format them
create_partitions() {
  # Create GPT partition table
  parted -s /dev/md10 mklabel gpt
  # Create 5 equal-sized partitions
  parted -s /dev/md10 mkpart primary ext4 1MiB 20%
  parted -s /dev/md10 mkpart primary ext4 20% 40%
  parted -s /dev/md10 mkpart primary ext4 40% 60%
  parted -s /dev/md10 mkpart primary ext4 60% 80%
  parted -s /dev/md10 mkpart primary ext4 80% 100%

  # Reload partition table
  partprobe /dev/md10
  udevadm settle
  # Format partitions
  for i in $(seq 1 5); do
    mkfs.ext4 -F /dev/md10p$i
  done

  # Create mount points
  mkdir -p /raid/part{1,2,3,4,5}

  # Mount partitions
  for i in $(seq 1 5); do
    mount /dev/md10p$i /raid/part$i
  done
}

# Persist mounts across reboot
configure_fstab() {
  for i in $(seq 1 5); do
    uuid=$(blkid -s UUID -o value /dev/md10p$i)
    echo "UUID=${uuid} /raid/part$i ext4 defaults 0 2" >> /etc/fstab
  done
}

main() {
  install_mdadm
  create_raid
  check_raid
  create_partitions
  save_raid
  configure_fstab
  mount -a
  # Show final RAID status
  check_raid
}

main "$@"

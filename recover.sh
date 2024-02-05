#!/usr/bin/env bash

set -e

echo "Current latest commit:"
git ls-remote -h https://github.com/rotteegher/rotfiles master
echo

function yesno() {
    local prompt="$1"

    while true; do
        read -rp "$prompt [y/n] " yn
        case $yn in
            [Yy]* ) echo "y"; return;;
            [Nn]* ) echo "n"; return;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

BOOTDISK=$(readlink -f /dev/disk/by-label/NIXBOOT)

# Check if boot mounted
if mountpoint -q /mnt/boot; then
    sudo umount -f /mnt/boot
fi
reformat_boot=$(yesno "Reformat boot?")
if [[ $reformat_boot == "y" ]]; then
    sudo mkfs.fat -F 32 "$BOOTDISK" -n NIXBOOT
fi

# Check if zroot pool exists
if zpool list zroot; then
    echo "Zpool 'zroot' already exists"
else 
    # -l prompts for passphrase if needed
    echo "Importing zpool"
    sudo zpool import -f -l zroot
fi

reformat_nix=$(yesno "Reformat nix?")
if [[ $reformat_nix == "y" ]]; then
    sudo zfs destroy -r zroot/nix

    sudo zfs create -o mountpoint=legacy zroot/nix
    sudo mkdir -p /mnt/nix
    sudo mount -t zfs zroot/nix /mnt/nix
fi

if mountpoint -q /mnt; then
    echo "Already mounted"
else
    echo "Mounting Disks"

    sudo mount --mkdir -t zfs zroot/root /mnt
    sudo mount --mkdir "$BOOTDISK" /mnt/boot
    sudo mount --mkdir -t zfs zroot/nix /mnt/nix
    sudo mount --mkdir -t zfs zroot/tmp /mnt/tmp
    sudo mount --mkdir -t zfs zroot/home /mnt/home
    # sudo mount --mkdir -t zfs zroot/persist /mnt/persist
    sudo mount --mkdir -t zfs zroot/cache /mnt/cache
fi

# handle persist, possibly from snapshot
restore_snapshot=$(yesno "Do you want to restore from a persist snapshot?")
snapshot_type=$(yesno "Is snapshot a file?")
if [[ "$restore_snapshot" == "y" ]]; then

    if [[ "$snapshot_type" == "y" ]]; then
        echo "Enter full path to snapshot: "
        read -r snapshot_file_path
        echo

        echo "Creating /persist"
        # shellcheck disable=SC2024 (sudo doesn't affect redirects)
        sudo zfs receive -o mountpoint=legacy zroot/persist < "$snapshot_file_path"
    else
        echo "Listing snapshots:"
        zfs list -t snapshot
        echo
        echo "Example: zroot/persist@autosnap_2024-02-14_05:0:25_hourly"
        echo "Example2: tank/data@persist_snapshot_2024"
        echo "Enter snapshot NAME to 'zfs send' to 'zroot/persist':"
        read -r snapshot_name
        echo

        echo "Creating /persist"
        sudo zfs send $snapshot_name | sudo zfs receive -o mountpoint=legacy zroot/persist
    fi
else
    echo "Creating /persist"
    sudo zfs create -o mountpoint=legacy zroot/persist
fi
sudo mount --mkdir -t zfs zroot/persist /mnt/persist


echo "Listing of block devices:"
lsblk

while true; do
    read -rp "Which host to install? (desktop / omen ) " host
    case $host in
        desktop|omen ) break;;
        * ) echo "Invalid host. Please select a valid host.";;
    esac
done

read -rp "Enter git rev for flake (default: master): " git_rev
echo "Reinstalling NixOS"
sudo nixos-install --no-root-password --flake "github:rotteegher/rotfiles/${git_rev:-master}#$host"

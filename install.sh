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

function prompt_for_password() {
    while true; do
        # Prompt for password
        read -rs -p "Enter root password: " password
        printf "\n"

        # Prompt for password confirmation
        read -rs -p "Confirm root password: " confirm_password
        printf "\n"

        # Check if passwords match
        if [ "$password" == "$confirm_password" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done

    # Return the entered password
    echo "$password"
}

cat << Introduction
This script will format the *entire* disk with a 1GB boot partition
(labelled NIXBOOT), 16GB of swap, then allocating the rest to ZFS.

OR BY CHOICE

This script will format selected by user boot, swap, root partitions
on already existing partition table.

The following ZFS datasets will be created on the root:
    - zroot/root (mounted at / with blank snapshot)
    - zroot/nix (mounted at /nix)
    - zroot/tmp (mounted at /tmp)
    - zroot/persist (mounted at /persist)
    - zroot/persist/cache (mounted at /persist/cache)

Introduction

# in a vm, special case
if [[ -b "/dev/vda" ]]; then
    DISK="/dev/vda"
    
    BOOTDISK="${DISK}3"
    SWAPDISK="${DISK}2"
    ZFSDISK="${DISK}1"
    # normal disk
else


cat << FormatWarning
YOUR DISK IS ABOUT TO BE FORMATTED

Please select the disk by id to be formatted.
(e.g. nvme-eui.0123456789). Your devices are shown below:

FormatWarning
    
install_type=$(yesno "Do you wish to install onto a whole empty disk [y]; or select existing partitions manually? [n];")

    if [[ $install_type == "y" ]]; then

# FULL DISK SELECTION

# Select whole disk
DISKINPUT=$(ls -r /dev/disk/by-id/ | fzf --prompt="Select disk to install nixos on [WITHOUT '-part']: " | cut -d ' ' -f 1)

        if [[ $DISKINPUT == *part* ]]; then
            echo "Error: Select full disk without 'part' in the id name."
            exit
        fi

        echo "Your disk is: $DISKINPUT"

        echo ""

        DISK="/dev/disk/by-id/${DISKINPUT}"
        # Check if the specified disk exists
        if [[ -e $DISK && ! -d $DISK ]]; then
            BOOTDISK="${DISK}-part3"
            SWAPDISK="${DISK}-part2"
            ZFSDISK="${DISK}-part1"
        else
            echo "Error: Disk not found in /dev/disk/by-id directory."
            exit
        fi

        # Selected partitions
        echo "Selected partitions:"
        echo "    Boot Partiton [NIXBOOT] - '$BOOTDISK'"
        echo "    SWAP Partiton [SWAP] - '$SWAPDISK'"
        echo "    ZFS Root Partiton [zroot] - '$ZFSDISK'"

        # Format Confirmation
        do_format=$(yesno "This irreversibly formats the entire disk. Are you sure?")
        if [[ $do_format != "y" ]]; then
            exit
        fi

        # warning countdown
        for i in {5..0}; do
            echo -ne "Formatting in $i seconds... <Ctrl + C> to EXIT NOW\r"
            sleep 1
        done

        # DO INSTALL FULL DISK

        # RUN CHECKS
        echo "Checking mountpoint ''/mnt/boot':"
        # Check boot partition
        sudo mkdir -p /mnt/boot
        if mountpoint -q /mnt/boot; then
            echo "Unmounting /mnt/boot"
            sudo umount -f /mnt/boot || true
        fi

        echo "Checking swap status for: $SWAPDISK"
        # Check swap partition
        if [ -b "$SWAPDISK" ]; then
            swap_device=$(readlink -f "$SWAPDISK")
            echo "Swap device: $swap_device"

            # Check if the swap is currently on
            if swapon --show | grep -q "$swap_device"; then
                echo "Swap '$swap_device' is currently on."
                echo "Turning off SWAP device: $SWAPDISK"
                sudo swapoff "$SWAPDISK"
            else
                echo "Swap is already off. Continuing..."
            fi
        fi

        echo "Checking 'zroot' pool:"
        # Check if zroot pool exists
        if zpool list zroot; then
            do_reinstall=$(yesno "'zroot' zfs pool already exists. Reinstall filesystem?")
            if [[ $do_reinstall == "y" ]]; then
                echo "Destroying zroot"
                sudo zpool destroy zroot
            else
                exit
            fi
        fi

        # POPULATE PARTITIONS ON THE WHOLE DISK
        echo "Creating partitions"
        sudo blkdiscard -f "$DISK"

        echo "Creating Boot partition"
        sudo sgdisk -n3:1M:+1G -t3:EF00 "$DISK"
        echo "Creating Swap partition"
        sudo sgdisk -n2:0:+16G -t2:8200 "$DISK"
        echo "Creating Root partition for the remainder of the disk"
        sudo sgdisk -n1:0:0 -t1:BF01 "$DISK"

        # notify kernel of partition changes
        sudo sgdisk -p "$DISK" > /dev/null
        sync
        sleep 5

        echo "Formatting Boot partition"
        sudo mkfs.fat -F 32 "$BOOTDISK"
        sudo fatlabel "$BOOTDISK" NIXBOOT

        echo "Setting up Swap"
        sudo mkswap "$SWAPDISK" -L "SWAP"
        sudo swapon "$SWAPDISK"

        # setup encryption
        use_encryption=$(yesno "Use encryption? (Encryption must also be enabled within host config.)")
        if [[ $use_encryption == "y" ]]; then
            encryption_options=(-O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt)
        else
            encryption_options=()
        fi

        echo "Proceeding to ZFS setup..."

    else

# MANUAL PARTITION SELECTION
        BOOTDISK_INPUT=$(ls -r /dev/disk/by-id/ | fzf --prompt="Select Boot Partition: " | cut -d ' ' -f 1)
        SWAPDISK_INPUT=$(ls -r /dev/disk/by-id/ | fzf --prompt="Select Swap Partition: " | cut -d ' ' -f 1)
        ZFSDISK_INPUT=$(ls -r /dev/disk/by-id/ | fzf --prompt="Select ZFS Root Partition [zroot]: " | cut -d ' ' -f 1)

        BOOTDISK="/dev/disk/by-id/${BOOTDISK_INPUT}"
        SWAPDISK="/dev/disk/by-id/${SWAPDISK_INPUT}"
        ZFSDISK="/dev/disk/by-id/${ZFSDISK_INPUT}"

        # CHECK Selected partitions
        echo "Selected partitions:"
        if [[ -e $BOOTDISK && ! -d $BOOTDISK ]]; then
            echo "    Boot Partiton [NIXBOOT] - '$BOOTDISK'"
        else
            echo "'$BOOTDISK' does not exist!"
            exit
        fi
        if [[ -e $SWAPDISK && ! -d $SWAPDISK ]]; then
            echo "    SWAP Partiton [SWAP] - '$SWAPDISK'"
        else
            echo "'$BOOTDISK' does not exist!"
            exit
        fi
        if [[ -e $ZFSDISK && ! -d $ZFSDISK ]]; then
            echo "    ZFS Root Partiton [zroot] - '$ZFSDISK'"
        else
            echo "'$BOOTDISK' does not exist"
            exit
        fi

        # Format Confirmation
        do_format=$(yesno "This irreversibly formats selected partitions. Are you sure?")
        if [[ $do_format != "y" ]]; then
            exit
        fi

        # warning countdown
        for i in {5..0}; do
            echo -ne "Formatting in $i seconds... <Ctrl + C> to EXIT NOW\r"
            sleep 1
        done


        # DO INSTALL MANUAL SELECTION

        # RUN CHECKS
        echo "Checking mountpoint ''/mnt/boot':"
        # Check boot partition
        sudo mkdir -p /mnt/boot
        if mountpoint -q /mnt/boot; then
            echo "Unmounting /mnt/boot"
            sudo umount -f /mnt/boot || true
        fi

        echo "Checking swap status for: $SWAPDISK"
        # Check swap partition
        if [ -b "$SWAPDISK" ]; then
            swap_device=$(readlink -f "$SWAPDISK")
            echo "Swap device: $swap_device"

            # Check if the swap is currently on
            if swapon --show | grep -q "$swap_device"; then
                echo "Swap '$swap_device' is currently on."
                echo "Turning off SWAP device: $SWAPDISK"
                sudo swapoff "$SWAPDISK"
            else
                echo "Swap is already off. Continuing..."
            fi
        fi

        echo "Checking 'zroot' pool:"
        # Check if zroot pool exists
        if zpool list zroot; then
            do_reinstall=$(yesno "'zroot' zfs pool already exists. Reinstall filesystem?")
            if [[ $do_reinstall != "y" ]]; then
                exit
            else
                echo "Destroying zroot"
                sudo zpool destroy zroot
            fi
        fi
        
        # FORMAT PARTITIONS
       
        echo "Discarding selected partitions!"
        sudo blkdiscard -f "$BOOTDISK"
        sudo blkdiscard -f "$SWAPDISK"
        sudo blkdiscard -f "$ZFSDISK"

        # notify kernel of partition changes
        sudo sgdisk -p "$BOOTDISK" > /dev/null
        sudo sgdisk -p "$SWAPDISK" > /dev/null
        sudo sgdisk -p "$ZFSDISK" > /dev/null
        sync
        sleep 5

        echo "Setting up Swap"
        sudo mkswap "$SWAPDISK" -L "SWAP"
        sudo swapon "$SWAPDISK"

        echo "Formatting Boot Disk"
        sudo mkfs.fat -F 32 "$BOOTDISK"
        sudo fatlabel "$BOOTDISK" NIXBOOT

        # setup encryption
        use_encryption=$(yesno "Use encryption? (Encryption must also be enabled within host config.)")
        if [[ $use_encryption == "y" ]]; then
            encryption_options=(-O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=prompt)
        else
            encryption_options=()
        fi

        echo "Proceeding to ZFS setup..."

    fi
fi

# ZFS

echo "Creating base zpool"
sudo zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -O compression=zstd \
    -O acltype=posixacl \
    -O atime=off \
    -O xattr=sa \
    -O normalization=formD \
    -O mountpoint=none \
    "${encryption_options[@]}" \
    zroot "$ZFSDISK"

echo "Creating /"
sudo zfs create -o mountpoint=legacy zroot/root
sudo zfs snapshot zroot/root@blank
sudo mount -t zfs zroot/root /mnt

# create the boot parition after creating root
echo "Mounting /boot (efi)"
sudo mount --mkdir "$BOOTDISK" /mnt/boot

echo "Creating /nix"
sudo zfs create -o mountpoint=legacy zroot/nix
sudo mount --mkdir -t zfs zroot/nix /mnt/nix

echo "Creating /tmp"
sudo zfs create -o mountpoint=legacy zroot/tmp
sudo mount --mkdir -t zfs zroot/tmp /mnt/tmp

echo "Creating /cache"
sudo zfs create -o mountpoint=legacy zroot/cache
sudo mount --mkdir -t zfs zroot/cache /mnt/cache

# handle persist, possibly from snapshot
restore_snapshot=$(yesno "Do you want to restore from a persist snapshot?")
if [[ "$restore_snapshot" == "y" ]]; then
snapshot_type=$(yesno "Is snapshot a file?")
    if [[ "$snapshot_type" == "y" ]]; then
        echo "Tip: use 'zfs send zroot/persist@snapshotname > /path/to/snapshotfile ' to persist create snapshot file."
        echo "Enter full path to snapshot: "
        read -r snapshot_file_path
        echo

        echo "Creating /persist"
        # shellcheck disable=SC2024 (sudo doesn't affect redirects)
        sudo zfs receive -o mountpoint=legacy zroot/persist < "$snapshot_file_path"
    else
snapshot_name=$(zfs list -H -t snapshot -r | fzf --prompt="Select snapshot to restore from: " | awk '{print $1}')
        echo "Selected snapshot: $snapshot_name"
        echo "Creating /persist from snapshot"
        sudo zfs send -v $snapshot_name | sudo zfs receive -v -o mountpoint=legacy zroot/persist
        echo "Completed persist snapshot send: "
        zfs list -o name,refer -t snapshot zroot/persist
        zfs list -o name,used zroot/persist
    fi
else
    echo "Creating empty /persist"
    sudo zfs create -o mountpoint=legacy zroot/persist
fi

echo "Mounting persist"
sudo mount --mkdir -t zfs zroot/persist /mnt/persist

echo "Listing of block devices: "
lsblk -o NAME,SIZE,TYPE,LABEL,ID-LINK

echo "ZFS pools:"
zpool list
echo "ZFS filesystems: "
zfs list -t filesystem

read -rp "Enter git rev for flake (default: master): " git_rev
# use fzf to select host
host=$(echo -e "desktop\nomen" | fzf --prompt="Select a host to install: ")

echo "Installing NixOS"
sudo nixos-install --flake "github:rotteegher/rotfiles/${git_rev:-master}#$host"

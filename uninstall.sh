#!/bin/bash

# Variables
CONTAINER_STORAGE="/cryptstore"
CONTAINER_FILE="LUKS"
MOUNT_DIRECTORY="/secureLUKS"
MAPPER="LUKSUnlock"
YUBIKEY_LUKS_UNLOCK_SCRIPT="/usr/local/bin/yubikey-luks-unlock"
YUBIKEY_LUKS_UNLOCK_SERVICE="/etc/systemd/system/yubikey-luks-unlock.service"

# Parse command line options
while getopts "s:f:d:m:h" opt; do
  case $opt in
    s) CONTAINER_STORAGE=$OPTARG ;;
    f) CONTAINER_FILE=$OPTARG ;;
    d) MOUNT_DIRECTORY=$OPTARG ;;
    m) MAPPER=$OPTARG ;;
    h) echo "Usage: $0 [-s CONTAINER_STORAGE] [-f CONTAINER_FILE] [-d MOUNT_DIRECTORY] [-m MAPPER]"
       echo "  -s: Container storage path (default: /cryptstore)"
       echo "  -f: Container file name (default: LUKS)"
       echo "  -d: Mount directory (default: /secureLUKS)"
       echo "  -m: Mapper name (default: LUKSUnlock)"
       exit 0 ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1 ;;
  esac
done

# Disclaimer
echo "This script will UNINSTALL the LUKS container unlocked by YubiKey setup."
echo "It will NOT delete the LUKS container if you changed the default install locataon." 
echo "You can use args to specify your enviornment, or it will only be able to remove the YubiKey configuration and related files."
echo "Please ensure that you have backed up any important data before proceeding."

# Prompt for confirmation
read -p "Do you wish to continue with the uninstallation? (y/N): " user_confirmation
case $user_confirmation in
    [Yy]* ) ;;
    * ) echo "Uninstallation aborted by user."; exit 1;;
esac
# Additional safety check: Confirm with the user before proceeding
echo "WARNING: This will permanently delete the LUKS container and all its data."
read -p "Are you sure you want to proceed? (y/N): " confirm_deletion
if [[ $confirm_deletion != "y" ]]; then
    echo "Aborting uninstallation."
    exit 1
fi

# Unmount the container if mounted
if mount | grep -q $MOUNT_DIRECTORY; then
    echo "Unmounting $MOUNT_DIRECTORY..."
    sudo umount $MOUNT_DIRECTORY
fi

# Close the LUKS container
if [ -e "/dev/mapper/$MAPPER" ]; then
    echo "Closing the LUKS container..."
    sudo cryptsetup close $MAPPER
fi

# Remove the LUKS container file
if [ -f "$CONTAINER_STORAGE/$CONTAINER_FILE" ]; then
    echo "Removing the LUKS container file..."
    sudo rm -f "$CONTAINER_STORAGE/$CONTAINER_FILE"
fi

# Remove the systemd service
echo "Disabling and removing the YubiKey LUKS unlock service..."
sudo systemctl disable yubikey-luks-unlock.service
sudo systemctl stop yubikey-luks-unlock.service
sudo rm -f $YUBIKEY_LUKS_UNLOCK_SERVICE

# Remove the yubikey-luks-unlock script
echo "Removing the YubiKey unlock script..."
sudo rm -f $YUBIKEY_LUKS_UNLOCK_SCRIPT

# Optionally, remove packages. Warn user and ask for confirmation.
echo "The following packages were installed: cryptsetup, yubikey-manager, yubikey-personalization, pcscd."
read -p "Do you want to uninstall these packages? (y/N): " uninstall_pkgs
case $uninstall_pkgs in
    [Yy]* )
        echo "Uninstalling packages..."
        sudo apt-get remove --purge -y cryptsetup yubikey-manager yubikey-personalization pcscd
        ;;
    * ) echo "Skipping package uninstallation.";;
esac
systemctl daemon-reload
echo "Uninstallation complete."
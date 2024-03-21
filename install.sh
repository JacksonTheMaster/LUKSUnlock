#!/bin/bash

# Variables
CONTAINER_STORAGE="/cryptstore" # Container storage path
CONTAINER_FILE="LUKS" # Container file name
MOUNT_DIRECTORY="/home/jmg/secure" # Mount directory
FILE_SIZE_MB=276 # Size of the container in megabytes
MAPPER="LUKSYubiKey"

# Create the container storage location
sudo mkdir -p $CONTAINER_STORAGE

# Create the empty container
sudo dd if=/dev/zero of=$CONTAINER_STORAGE/$CONTAINER_FILE bs=1M count=$FILE_SIZE_MB

# Install necessary packages
sudo apt-get update
sudo apt-get install -y cryptsetup
sudo apt-get install -y yubikey-manager yubikey-personalization pcscd

# Initialize and open the LUKS container
sudo cryptsetup luksFormat $CONTAINER_STORAGE/$CONTAINER_FILE
sudo cryptsetup open $CONTAINER_STORAGE/$CONTAINER_FILE $MAPPER

# Format the container with ext4
sudo mkfs.ext4 /dev/mapper/$MAPPER

# Create a directory for mounting the container
sudo mkdir -p $MOUNT_DIRECTORY

# Mount the container
sudo mount /dev/mapper/$MAPPER $MOUNT_DIRECTORY

# Configure the YubiKey
sudo systemctl start pcscd
sudo systemctl enable pcscd
echo "enter y"
ykman otp chalresp --generate 2
YUBIKEY_RESPONSE=$(ykchalresp -2 "LUKSChallenge")
echo "USE THIS NEW PASSPHRASE IN THE 2nd NEXT PROMPT:"
echo "I have no idea why we get the first one :D"
echo "$YUBIKEY_RESPONSE"
sudo cryptsetup luksAddKey $CONTAINER_STORAGE/$CONTAINER_FILE

sudo curl -o /usr/local/bin/yubikey-luks-unlock https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/yubikey-luks-unlock

sudo chmod +x /usr/local/bin/yubikey-luks-unlock

#Systemd Service
sudo curl -o /etc/systemd/system/yubikey-luks-unlock.service https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/yubikey-luks-unlock.service

sudo umount $MOUNT_DIRECTORY
sudo cryptsetup close $MAPPER

# Activate and start the systemd service
sudo systemctl enable yubikey-luks-unlock.service
sudo systemctl start yubikey-luks-unlock.service

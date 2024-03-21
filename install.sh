#!/bin/bash

# Variables
CONTAINER_STORAGE="/cryptstore" # Container storage path
CONTAINER_FILE="LUKS" # Container file name
MOUNT_DIRECTORY="/secureLUKS" # Mount directory
FILE_SIZE_MB=276 # Size of the container in megabytes
MAPPER="LUKSUnlock"

# Disclaimer and prerequisites
echo "Disclaimer: This installer will configure a LUKS container to be unlocked with a YubiKey on boot."
echo "Prerequisites:"
echo "- A plugged in YubiKey with OTP slot 2 empty"
echo "- Sudo privileges"
echo "- Internet connection for downloading necessary packages and scripts."
echo "This script requires user inputs. Do NOT curl this into bash."
echo "Make sure to safely store the first passphrase you set up"
echo "Please ensure all prerequisites are met before proceeding."

# Prompt user for confirmation
read -p "Do you wish to continue with the installation? (y/N): " user_confirmation
case $user_confirmation in
    [Yy]* ) ;;
    * ) echo "Installation aborted by user."; exit 1;;
esac

# Parse command line options
while getopts "s:f:d:b:m:h" opt; do
  case $opt in
    s) CONTAINER_STORAGE=$OPTARG ;;
    f) CONTAINER_FILE=$OPTARG ;;
    d) MOUNT_DIRECTORY=$OPTARG ;;
    b) FILE_SIZE_MB=$OPTARG ;;
    m) MAPPER=$OPTARG ;;
    h) echo "Usage: $0 [-s CONTAINER_STORAGE] [-f CONTAINER_FILE] [-d MOUNT_DIRECTORY] [-b FILE_SIZE_MB] [-m MAPPER]"
       echo "  -s: Container storage path (default: /cryptstore)"
       echo "  -f: Container file name (default: LUKS)"
       echo "  -d: Mount directory (default: /secureLUKS)"
       echo "  -b: Size of the container in megabytes (default: 276)"
       echo "  -m: Mapper name (default: LUKSUnlock)"
       exit 0 ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1 ;;
  esac
done

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
# Replace placeholders in the yubikey-luks-unlock script
sudo sed -i "s#\${DEVICE}#$CONTAINER_STORAGE/$CONTAINER_FILE#g" /usr/local/bin/yubikey-luks-unlock
sudo sed -i "s#\${MAPPER}#$MAPPER#g" /usr/local/bin/yubikey-luks-unlock
sudo sed -i "s#\${MOUNT_POINT}#$MOUNT_DIRECTORY#g" /usr/local/bin/yubikey-luks-unlock

sudo chmod +x /usr/local/bin/yubikey-luks-unlock

#Systemd Service
sudo curl -o /etc/systemd/system/yubikey-luks-unlock.service https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/yubikey-luks-unlock.service

sudo umount $MOUNT_DIRECTORY
sudo cryptsetup close $MAPPER

# Activate and start the systemd service
sudo systemctl enable yubikey-luks-unlock.service
sudo systemctl start yubikey-luks-unlock.service

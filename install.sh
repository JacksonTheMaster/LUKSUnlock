#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
CONTAINER_STORAGE="/cryptstore" # Container storage path
CONTAINER_FILE="LUKS" # Container file name
MOUNT_DIRECTORY="/secureLUKS" # Mount directory
FILE_SIZE_MB=276 # Size of the container in megabytes
MAPPER="LUKSUnlock"

# Disclaimer and prerequisites
echo -e "${YELLOW}Disclaimer:${NC} This installer will configure a LUKS container to be unlocked with a YubiKey on boot."
echo -e "${YELLOW}Prerequisites:${NC}"
echo "- A plugged in YubiKey with OTP slot 2 empty"
echo "- Sudo privileges"
echo "- Internet connection for downloading necessary packages and scripts."
echo "This script requires user inputs. Do NOT curl this into bash."
echo "Make sure to safely store the first passphrase you set up"
echo "Please ensure all prerequisites are met before proceeding."



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

# Prompt user for confirmation
read -p "Do you wish to continue with the installation? (y/N): " user_confirmation
case $user_confirmation in
    [Yy]* ) ;;
    * ) echo -e "${RED}Installation aborted by user.${NC}"; exit 1;;
esac

# Create the container storage location
sudo mkdir -p $CONTAINER_STORAGE

# Creating the empty container
echo -e "${GREEN}Creating an empty container of size ${FILE_SIZE_MB}MB...${NC}"
echo -e "${GREEN}This could take a while${NC}"
sudo dd if=/dev/zero of=$CONTAINER_STORAGE/$CONTAINER_FILE bs=1M count=$FILE_SIZE_MB

# Installing necessary packages
echo -e "${GREEN}Installing necessary packages...${NC}"
sudo apt-get update
sudo apt-get install -y cryptsetup
sudo apt-get install -y yubikey-manager yubikey-personalization pcscd

# Initialize and open the LUKS container
echo -e "${GREEN}Initializing and opening the LUKS container...${NC}"
echo -e "${RED}Here, you set the first / recovery passphrase for your Secure Store. Keep this passphrase secret, and don't loose it.${NC}"
sudo cryptsetup luksFormat $CONTAINER_STORAGE/$CONTAINER_FILE
sudo cryptsetup open $CONTAINER_STORAGE/$CONTAINER_FILE $MAPPER

# Formatting the container
echo -e "${GREEN}Formatting the container with ext4...${NC}"
sudo mkfs.ext4 /dev/mapper/$MAPPER

# Mounting the container
echo -e "${GREEN}Mounting the container...${NC}"
sudo mkdir -p $MOUNT_DIRECTORY
sudo mount /dev/mapper/$MAPPER $MOUNT_DIRECTORY

# Configure the YubiKey
sudo systemctl start pcscd
sudo systemctl enable pcscd
echo -e "\033[0;32mStarting YubiKey configuration for challenge-response...\033[0m"
echo -e "\033[0;33mYou will be prompted to confirm programming a challenge-response credential in slot 2.\033[0m"
echo -e "\033[0;33mPlease press 'y' when prompted.\033[0m"
ykman otp chalresp --generate 2

echo -e "\033[0;32mGenerating a response from YubiKey for a fixed challenge to use as the new passphrase.\033[0m"
echo -e "\033[0;33mThis requires manual input. Please follow the instructions carefully.\033[0m"
echo -e "\033[0;33mA challenge-response has been generated. We will now add this as a new key to the LUKS container.\033[0m"
echo -e "\033[0;33mFirst, you will be prompted for an existing passphrase to authorize adding the new key.\033[0m"
echo -e "\033[0;33mAfterward, you will be asked to enter a 'new passphrase'. Here, input the YubiKey response shown below.\033[0m"
YUBIKEY_RESPONSE=$(ykchalresp -2 "LUKSChallenge")
echo -e "\033[0;34mYubiKey response: Use this as the new passphrase when prompted.\033[0m"
echo -e "\033[0;34m$YUBIKEY_RESPONSE\033[0m"
echo -e "\033[0;32mProceeding to add a new key to the LUKS container. Start with the existing passphrase!.\033[0m"
sudo cryptsetup luksAddKey $CONTAINER_STORAGE/$CONTAINER_FILE

echo -e "\033[0;32mThe YubiKey has been configured, rather or not successfully.. Remember, the response shown above is also a new passphrase in case manual unlocking is required.\033[0m"


sudo curl -o /usr/local/bin/yubikey-luks-unlock https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/yubikey-luks-unlock
# Replace placeholders in the yubikey-luks-unlock script
sudo sed -i "s#\${DEVICE}#$CONTAINER_STORAGE/$CONTAINER_FILE#g" /usr/local/bin/yubikey-luks-unlock
sudo sed -i "s#\${MAPPER}#$MAPPER#g" /usr/local/bin/yubikey-luks-unlock
sudo sed -i "s#\${MOUNT_POINT}#$MOUNT_DIRECTORY#g" /usr/local/bin/yubikey-luks-unlock

sudo chmod +x /usr/local/bin/yubikey-luks-unlock

# Setting up systemd service
echo -e "${GREEN}Setting up systemd service for YubiKey LUKS unlock...${NC}"
sudo curl -o /etc/systemd/system/yubikey-luks-unlock.service https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/yubikey-luks-unlock.service

sudo umount $MOUNT_DIRECTORY
sudo cryptsetup close $MAPPER

# Activate and start the systemd service
sudo systemctl enable yubikey-luks-unlock.service
sudo systemctl start yubikey-luks-unlock.service

echo -e "${GREEN}Installation completed. Your system is now configured to unlock the LUKS container with a YubiKey on boot. Make sure to test it! If the LUKS works, you'll find a lost'nfound in your LUKS store.${NC}"

#!/bin/bash

# Check if the script is run as root (sudo)
if [ "$(id -u)" == "0" ]; then
    echo "This script musn't be run as root. Please run as your normal user."
    exit 1
fi

# Ask for the SSH key name
echo -n "Enter the name of the SSH key (default: id_ed25519): "
read SSH_KEY_NAME

# If user simply pressed Enter, use the default path
if [ -z "${SSH_KEY_NAME}" ]; then
    SSH_KEY_NAME="id_ed25519"
fi

SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

# Generate the SSH Key
ssh-keygen -t ed25519 -b 4096 -f "$SSH_KEY_PATH" -N ""

# echo the ssh pubkey content into stderr
echo ""
echo ""
echo "SSH public key:"
cat "$SSH_KEY_PATH.pub"
echo "You can configure your github account using the link below:"
echo "https://github.com/settings/keys"
>&2 echo "$SSH_KEY_PATH.pub"
exit
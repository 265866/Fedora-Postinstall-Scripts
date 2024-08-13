#!/bin/bash

# Check for unattended flag
UNATTENDED=0
if [[ "$1" == "--unattended" ]]; then
    UNATTENDED=1
fi

# Function to prompt yes/no questions
function prompt_yes_no() {
    if [ $UNATTENDED -eq 1 ]; then
        return 0 # Assume "yes" for all prompts
    fi

    while true; do
        read -p "$(echo -e "$1")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "${YELLOW}Please answer y or n.${NC}";;
        esac
    done
}

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Disable mouse acceleration
echo -e "${CYAN}Disabling mouse acceleration...${NC}"
sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# Ask if user wants to disable and mask automatic bug reporting services (ABRT)
if prompt_yes_no "${BLUE}Would you like to disable and mask automatic bug reporting services (ABRT)? (y/n): ${NC}"; then
    systemctl disable --now abrt-watch-log abrt-journal-core abrt-oops abrt-xorg abrt-journal-qabrtd
    systemctl mask abrt-watch-log abrt-journal-core abrt-oops abrt-xorg abrt-journal-qabrtd
    echo -e "${GREEN}ABRT services disabled and masked${NC}"
else
    echo -e "${YELLOW}Skipping ABRT services disablement${NC}"
fi

# Ask if user wants to remove Fedora Workstation repositories
if prompt_yes_no "${BLUE}Would you like to remove Fedora Workstation repositories (more telemetry)? (y/n): ${NC}"; then
    dnf remove -y fedora-workstation-repositories
    echo -e "${GREEN}Fedora Workstation repositories removed${NC}"
else
    echo -e "${YELLOW}Skipping Fedora Workstation repositories removal${NC}"
fi

# Ask if user wants to remove default gnome apps
if prompt_yes_no "${BLUE}Would you like to remove default Gnome apps (Maps, Weather, Contacts, Music)? (y/n): ${NC}"; then
    dnf remove -y rhythmbox gnome-maps gnome-weather gnome-contacts gnome-photos gnome-music
    echo -e "${GREEN}Default Gnome apps removed${NC}"
else
    echo -e "${YELLOW}Skipping Gnome apps removal${NC}"
fi

# Ask if user wants to remove default libreoffice apps
if prompt_yes_no "${BLUE}Would you like to remove default Libreoffice apps? (y/n): ${NC}"; then
    dnf remove -y libreoffice*
    echo -e "${GREEN}Libreoffice suite removed${NC}"
else
    echo -e "${YELLOW}Skipping Libreoffice suite removal${NC}"
fi

echo -e "${CYAN}Autoremoving unneeded dependencies${NC}"
dnf autoremove -y

# Ask if user wants dark mode and theming and stuff
if prompt_yes_no "${BLUE}Would you like to use a dark theme? (y/n): ${NC}"; then
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" mkdir -p ~/.local/share/backgrounds/.hidden
    chown -R $(logname):$(logname) /home/$(logname)/.local/share/backgrounds/.hidden
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" bash -c 'HOME=/home/$(logname) wget -O ~/.local/share/backgrounds/.hidden/background.png https://raw.githubusercontent.com/265866/Fedora-Installation/main/fedora/background.png'
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" bash -c 'gsettings set org.gnome.desktop.background picture-uri "file:///home/$(logname)/.local/share/backgrounds/.hidden/background.png"'
    sudo -u "$(logname)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $(logname))/bus" bash -c 'gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$(logname)/.local/share/backgrounds/.hidden/background.png"'
    chmod 444 ~/.local/share/backgrounds/.hidden/background.png
    dnf install -y gnome-tweaks gtk3 gnome-themes-extra gtk-murrine-engine sassc
    flatpak install flathub com.mattjakeman.ExtensionManager -y
    
    echo -e "${GREEN}Dark theme added & Enabled${NC}"
else
    echo -e "${YELLOW}Skipping adding dark theme${NC}"
fi

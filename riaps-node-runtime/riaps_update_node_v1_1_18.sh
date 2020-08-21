#!/usr/bin/env bash
set -e

# Identify the host architecture
NODE_ARCH="armhf"
UBUNTU_VERSION_INSTALL="18.04"

# Username
RIAPSUSER="riaps"

# RIAPS Release Version
RIAPS_VERSION="v1.1.18"

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# For v1.1.18, riaps-pycom riaps.conf and riaps-log.conf files have been update
# it is best to remove the riaps-pycom-amd64 package completely and then reinstall
# Remember to update the nic name for /etc/riaps.conf after installation
sudo apt-get purge riaps-pycom-$NODE_ARCH -y

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-$NODE_ARCH riaps-pycom-$NODE_ARCH riaps-timesync-$NODE_ARCH -y

# install/remove new packages
sudo apt-get remove snapd -y
sudo apt-get purge snapd -y
echo ">>>>> snap package manager removed"

sudo apt-get install libcap-dev -y
sudo pip3 install 'python-prctl==1.7' --verbose
echo ">>>>> installed prctl"

sudo sed -i 's/bbb/riaps/g' /usr/bin/set_unique_hostname
echo ">>>>> change host name to be riaps-, instead of bbb-"

mkdir -p /home/$RIAPSUSER/.riaps
echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
echo "Ubuntu Version: $UBUNTU_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
echo ">>>>> Created RIAPS version log file"

echo "updated RIAPS platform to v1_1_18"

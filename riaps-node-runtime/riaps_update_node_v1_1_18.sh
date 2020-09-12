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


# Update Security Packages
sudo pip3 install 'paramiko==2.7.1' --verbose
sudo pip3 install --ignore-installed 'cryptography==2.9.2'
echo ">>>>> update security packages setup"

# New package for v1.1.18
PREVIOUS_PWD=$PWD
TMP=`mktemp -d`
git clone https://github.com/RIAPS/python-prctl.git $TMP/python-prctl
cd $TMP/python-prctl/
git checkout feature-ambient
sudo python3 setup.py install
cd $PREVIOUS_PWD
sudo rm -rf $TMP
echo ">>>>> installed prctl"

# Update rpyc
sudo pip3 install 'rpyc==1.4.5'

# Moving to generic host name for remote nodes (riaps-xxxx)
sudo sed -i 's/bbb/riaps/g' /usr/bin/set_unique_hostname
echo ">>>>> change host name to be riaps-, instead of bbb-"

# Add a version log file for debugging
mkdir -p /home/$RIAPSUSER/.riaps
echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
echo "Ubuntu Version: $UBUNTU_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
echo ">>>>> Created RIAPS version log file"

echo "updated RIAPS platform to v1_1_18"

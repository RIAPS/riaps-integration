#!/usr/bin/env bash
set -e 

# Add RIAPS repository
if grep -q 'deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main' /etc/apt/sources.list ; 
then
    echo "RIAPS repository is already included."
else
    sudo echo " "
    sudo echo "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main" >> /etc/apt/sources.list
fi

sudo apt-get install riaps-release/riaps-externals-armhf.deb
echo "installed externals"
sudo apt-get install riaps-release/riaps-core-armhf.deb
echo "installed core"
sudo apt-get install riaps-release/riaps-pycom-armhf.deb
echo "installed pycom"
sudo apt-get install riaps-release/riaps-systemd-armhf.deb 
echo "installed services"
sudo apt-get install riaps-release/riaps-timesync-armhf.deb 
echo "installed timesync"
echo "installed RIAPS platform"
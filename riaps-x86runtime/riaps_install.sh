#!/usr/bin/env bash
set -e 

# Add RIAPS repository
if grep -q 'deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main' /etc/apt/sources.list ; 
then
    echo "RIAPS repository is already included."
else
    sudo echo " "
    sudo echo "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main" >> /etc/apt/sources.list
fi

sudo apt-get install riaps-release/riaps-externals-amd64.deb
echo "installed externals"
sudo apt-get install riaps-release/riaps-core-amd64.deb
echo "installed core"
sudo apt-get install riaps-release/riaps-pycom-amd64.deb
echo "installed pycom"
sudo apt-get install riaps-release/riaps-systemd-amd64.deb 
echo "installed services"
sudo apt-get install riaps-release/riaps-timesync-amd64.deb 
echo "installed timesync"
echo "installed RIAPS platform"

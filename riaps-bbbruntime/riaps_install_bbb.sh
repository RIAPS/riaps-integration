#!/usr/bin/env bash
set -e 

sudo apt-get install riaps-externals-armhf.deb
echo "installed externals"
sudo apt-get install riaps-core-armhf.deb
echo "installed core"
sudo apt-get install riaps-pycom-armhf.deb
echo "installed pycom"
sudo apt-get install riaps-systemd-armhf.deb 
echo "installed services"
sudo apt-get install riaps-timesync-armhf.deb 
echo "installed timesync"
echo "installed RIAPS platform"
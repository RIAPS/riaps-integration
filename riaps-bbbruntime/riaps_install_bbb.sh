#!/usr/bin/env bash
set -e 

sudo apt-get install riaps-externals-armhf
echo "installed externals"
sudo apt-get install riaps-core-armhf
echo "installed core"
sudo apt-get install riaps-pycom-armhf
echo "installed pycom"
sudo apt-get install riaps-systemd-armhf 
echo "installed services"
sudo apt-get install riaps-timesync-armhf 
echo "installed timesync"
echo "installed RIAPS platform"
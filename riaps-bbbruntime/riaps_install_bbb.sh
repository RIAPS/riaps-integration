#!/usr/bin/env bash
set -e 

sudo apt-get install riaps-externals-armhf -y
echo "installed externals"
sudo apt-get install riaps-core-armhf -y
echo "installed core"
sudo apt-get install riaps-pycom-armhf -y
echo "installed pycom"
sudo apt-get install riaps-systemd-armhf -y
echo "installed services"
sudo apt-get install riaps-timesync-armhf -y
echo "installed timesync"
echo "installed RIAPS platform"
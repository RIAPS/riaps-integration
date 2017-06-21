#!/usr/bin/env bash
set -e 

tar -xzvf riaps-release.tar.gz
sudo dpkg -i riaps-release/riaps-externals-armhf.deb
echo "installed externals"
sudo dpkg -i riaps-release/riaps-core-armhf.deb
echo "installed core"
sudo dpkg -i riaps-release/riaps-pycom-armhf.deb
echo "installed pycom"
sudo dpkg -i riaps-release/riaps-systemd-armhf.deb 
echo "installed services"
sudo dpkg -i riaps-release/riaps-timesync-armhf.deb 
echo "installed timesync"

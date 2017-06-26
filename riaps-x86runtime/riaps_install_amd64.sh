#!/usr/bin/env bash
set -e 

sudo apt-get install riaps-externals-amd64 -y
echo "installed externals"
sudo apt-get install riaps-core-amd64 -y
echo "installed core"
sudo apt-get install riaps-pycom-amd64 -y
echo "installed pycom"
sudo apt-get install riaps-systemd-amd64 -y
echo "installed services"
sudo apt-get install riaps-timesync-amd64 -y
echo "installed timesync"
echo "installed RIAPS platform"

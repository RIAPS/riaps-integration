#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y
echo "installed RIAPS platform"

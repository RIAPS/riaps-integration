#!/usr/bin/env bash
set -e

# Identify the host architecture
HOST_ARCH="$(dpkg --print-architecture)"


# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-pycom-dev riaps-timesync-$HOST_ARCH -y
echo "installed RIAPS platform"

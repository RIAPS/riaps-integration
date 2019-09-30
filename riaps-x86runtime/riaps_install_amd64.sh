#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-amd64 riaps-pycom-amd64 riaps-timesync-amd64 -y
echo "installed RIAPS platform"

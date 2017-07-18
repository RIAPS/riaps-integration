#!/usr/bin/env bash
set -e 

sudo apt-get install rdate
sudo rdate -n -4 time-a.nist.gov

sudo apt-get install riaps-externals-armhf riaps-core-armhf riaps-pycom-armhf riaps-systemd-armhf riaps-timesync-armhf -y
echo "installed RIAPS platform"

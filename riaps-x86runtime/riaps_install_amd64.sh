#!/usr/bin/env bash
set -e 

sudo apt-get install rdate
sudo rdate -n -4 time-a.nist.gov

sudo apt-get update
sudo apt-get install riaps-externals-amd64 riaps-core-amd64 riaps-pycom-amd64 riaps-systemd-amd64 riaps-timesync-amd64 -y
echo "installed RIAPS platform"
 

#!/usr/bin/env bash
set -e

usage="$(basename "$0") [-d] [-h]
Create Debian packages for indicated architecture. Use -d to create a developer package.
Arguments are:
    -h show this help text
    -d install the developer package (optional)"

dev="false"

while getopts hd option
do
  case "$option" in 
    h) echo "$usage"; exit;;
    d) echo "Developer Package Selected"; dev="true";;
  esac
done

# Identify the host architecture
HOST_ARCH="$(dpkg --print-architecture)"

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# install RIAPS packages
sudo apt-get update

if [ $dev == "false" ]; then
  pycom_pkg_name="riaps-pycom"
else
  pycom_pkg_name="riaps-pycom-dev"
fi

sudo apt-get install $pycom_pkg_name riaps-timesync-$HOST_ARCH -y
echo "installed RIAPS platform"

#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# For v1.1.18, riaps-pycom riaps.conf and riaps-log.conf files have been update
# it is best to remove the riaps-pycom-amd64 package completely and then reinstall
# Remember to update the nic name for /etc/riaps.conf after installation
sudo apt-get purge riaps-pycom-armhf || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y

# new package installed
sudo apt-get install libcap-dev -y
git clone http://github.com/seveas/python-prctl
cd python-prctl/
python3 setup.py build
sudo python3 setup.py install

echo "installed RIAPS platform"

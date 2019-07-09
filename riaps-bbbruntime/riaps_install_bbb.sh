#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# uninstall deprecated package - riaps-systemd-<arch>
sudo dpkg -r riaps-systemd-amd64 || true
sudo dpkg --purge riaps-systemd-amd64 || true

# For v1.1.16, riaps-pycom and riaps-timesync uninstall package was modified
# fully remove packages and then remove extra files that no longer exist.
# This future releases, this will not be necessary.
sudo dpkg -r riaps-pycom-armhf || true
sudo dpkg -r riaps-timesync-armhf || true
sudo dpkg --purge riaps-pycom-armhf || true
sudo dpkg --purge riaps-timesync-armhf || true
sudo rm -f /etc/profile.d/10-riaps-external-armhf.sh || true
sudo rm -f /etc/apparmor.d/cache/usr.local.bin.riaps_actor || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-externals-armhf riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y
echo "installed RIAPS platform"

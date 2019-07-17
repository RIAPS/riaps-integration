#!/usr/bin/env bash
set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# uninstall deprecated package - riaps-systemd-<arch>
sudo apt-get purge riaps-systemd-armhf || true

# For v1.1.16, riaps-pycom and riaps-timesync uninstall package was modified
# fully remove packages and then remove extra files that no longer exist.
# This future releases, this will not be necessary.
sudo apt-get purge riaps-pycom-armhf || true
sudo apt-get purge riaps-timesync-armhf || true
sudo rm -f /etc/profile.d/10-riaps-external-armhf.sh || true
sudo rm -f /etc/apparmor.d/cache/usr.local.bin.riaps_actor || true
sudo rm -f /etc/timesync.role || true
sudo rm -f /etc/tsman.role || true
sudo rm -rf /usr/local/share/timesync || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-externals-armhf riaps-core-armhf riaps-pycom-armhf riaps-timesync-armhf -y
echo "installed RIAPS platform"

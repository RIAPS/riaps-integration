#!/usr/bin/env bash
set -e

# make sure date is correct
sudo apt-get install rdate
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# uninstall deprecated package - riaps-systemd-<arch>
sudo apt-get purge riaps-systemd-amd64 || true

# For v1.1.16, riaps-pycom and riaps-timesync uninstall package was modified
# fully remove packages and then remove extra files that no longer exist.
# This future releases, this will not be necessary.
sudo apt-get purge riaps-pycom-amd64 || true
sudo apt-get purge riaps-timesync-amd64 || true
sudo rm -f /etc/profile.d/10-riaps-external-amd64.sh || true
sudo rm -f /etc/apparmor.d/cache/usr.local.bin.riaps_actor || true
sudo rm -f /etc/timesync.role || true
sudo rm -f /etc/tsman.role || true
sudo rm -rf /usr/local/share/timesync || true
sudo rm -rf /usr/local/riaps/ || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-externals-amd64 riaps-core-amd64 riaps-pycom-amd64 riaps-timesync-amd64 -y
echo "installed RIAPS platform"

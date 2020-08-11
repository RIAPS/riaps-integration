#!/usr/bin/env bash
set -e

# Identify the host architecture
NODE_ARCH="armhf"
UBUNTU_VERSION_INSTALL="18.04"

# Username
RIAPSUSER="riaps"

# RIAPS Release Version
RIAPS_VERSION="v1.1.18"


source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`
    do
        source "$PWD/$SCRIPTS/$i"
    done
    echo ">>>>> sourced install scripts"
}

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# For v1.1.18, riaps-pycom riaps.conf and riaps-log.conf files have been update
# it is best to remove the riaps-pycom-amd64 package completely and then reinstall
# Remember to update the nic name for /etc/riaps.conf after installation
sudo apt-get purge riaps-pycom-$NODE_ARCH || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-$NODE_ARCH riaps-pycom-$NODE_ARCH riaps-timesync-$NODE_ARCH -y

# install/remove new packages
source_scripts
rm_snap_pkg
prctl_install
create_riaps_version_file
#MM TODO: need to setup/test - enable_cgroups

echo "updated RIAPS platform to v1_1_18"

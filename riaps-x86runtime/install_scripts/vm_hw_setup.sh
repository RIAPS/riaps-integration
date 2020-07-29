#!/usr/bin/env bash
set -e


# Script functions
check_os_version() {
    # Need to write code here to check OS version and architecture.
    # The installation should fail if the OS version is not correct.
    true

}

# Required for riaps-timesync
# Assumes libnss-mdns is already installed
timesync_requirements() {
    sudo apt-get install linuxptp gpsd chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo ">>>>> installed timesync requirements"
}

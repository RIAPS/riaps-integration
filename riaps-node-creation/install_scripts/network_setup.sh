#!/usr/bin/env bash
set -e

network_install() {
    sudo apt-get install net-tools -y
    echo "installed utils"
}

# MM TODO: net-tools is already install on BBB - make sure this does not cause issues in the script for BBBs
setup_network() {
    sudo apt-get install net-tools -y
    echo "replacing network/interfaces with network/interfaces-riaps"
    echo "copying old network/interfaces to network/interfaces.preriaps"
    touch /etc/network/interfaces
    cp /etc/network/interfaces /etc/network/interfaces.preriaps
    cp etc/network/interfaces-riaps /etc/network/interfaces
    echo "replaced network interfaces"

    echo "replacing resolv.conf"
    touch /etc/resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.preriaps
    cp  etc/resolv-riaps.conf /etc/resolv.conf
    echo "replaced resolv.conf"
}

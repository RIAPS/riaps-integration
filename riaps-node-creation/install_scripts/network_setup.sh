#!/usr/bin/env bash
set -e

network_install() {
    sudo apt-get install net-tools -y
    echo ">>>>> installed utils"
}

# net-tools is already installed on some architectures.  It is installed here to make sure it is available.
setup_network() {
    sudo apt-get install net-tools -y
    echo ">>>>> replacing network/interfaces with network/interfaces-riaps"
    echo ">>>>> copying old network/interfaces to network/interfaces.preriaps"
    touch /etc/network/interfaces
    cp /etc/network/interfaces /etc/network/interfaces.preriaps
    cp etc/network/interfaces-riaps /etc/network/interfaces
    echo ">>>>> replaced network interfaces"

    # Removing since not used with Netplan (Ubuntu's latest networking style)
    #echo ">>>>> replacing resolv.conf"
    #touch /etc/resolv.conf
    #cp /etc/resolv.conf /etc/resolv.conf.preriaps
    #cp  etc/resolv-riaps.conf /etc/resolv.conf
    #echo ">>>>> replaced resolv.conf"

    echo ">>>>> setup dhcp client configuration"
    touch /etc/systemd/network/dhcp.network
    cp etc/systemd/network/dhcp.network /etc/systemd/network/dhcp.network
}

#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-all-dev -y
    echo "installed boost"
}

# install nethogs pre-requisites
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    echo "installed nethogs prerequisites"
}

# MM TODO: libuuid1 & liblz4-1 is already install on RPi - make sure this does not cause issues in the script for RPis
# MM TODO: libuuid1 is already installed on BBB
zyre_czmq_prereq_install() {
    sudo apt-get install libzmq5 libzmq3-dev -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libuuid1 liblz4-1 -y
    sudo apt-get install pkg-config -y
    echo "installed CZMQ and Zyre prerequisites"
}

# Install security packages that take a long time compiling
#MM TODO: python3-crypto python3-keyrings.alt does not exist in RPi & BBB default setup - check that this does not cause issues
security_pkg_install() {
    echo "add security packages"
    sudo pip3 install 'paramiko==2.7.1' 'cryptography==2.9.2' --verbose
    sudo apt-get install apparmor-utils -y
    sudo apt-get remove python3-crypto python3-keyrings.alt -y
    echo "security packages setup"
}

#MM TODO: libgnutls30 exists in RPi and BBB default setup - check that this does not cause issues
# install gnutls
gnutls_install(){
    sudo apt-get install libgnutls30 libgnutls28-dev -y
    echo "installed gnutls"
}

#install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2 libmsgpack-dev -y
    echo "installed msgpack"
}

#install opendht prerequisites - expect libncurses5-dev installed
opendht_prereqs_install() {
    sudo apt-get install nettle-dev -y
    # run liblinks script to link gnutls and msgppack
    chmod +x /home/ubuntu/riaps-integration/riaps-node-creation/liblinks.sh
    PREVIOUS_PWD=$PWD
    cd /usr/lib/${ARCHINSTALL}
    sudo /home/ubuntu/riaps-integration/riaps-node-creation/liblinks.sh
    cd $PREVIOUS_PWD
    echo "installed opendht prerequisites"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libpcap-dev libreadline-dev libsystemd-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
    echo "removed packages used in building process, no longer needed"
}

setup_riaps_repo() {
    sudo apt-get install software-properties-common apt-transport-https -y

    # Add RIAPS repository
    echo "get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo "add repo to sources"
    sudo add-apt-repository -r "deb [arch=${ARCHTYPE}] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main" || true
    sudo add-apt-repository -n "deb [arch=${ARCHTYPE}] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main"
    sudo apt-get update
    echo "riaps aptrepo setup"
}

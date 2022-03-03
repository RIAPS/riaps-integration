#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-all-dev -y
    echo ">>>>> installed boost"
}

# install nethogs pre-requisites
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    echo ">>>>> installed nethogs prerequisites"
}

# libuuid1 & liblz4-1 are already installed on some architectures, but are needed for these package.
# Therefore, they are installed here to make sure they are available.
zyre_czmq_prereq_install() {
    sudo apt-get install libzmq5 libzmq3-dev -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libuuid1 liblz4-1 -y
    sudo apt-get install pkg-config libcurl4-gnutls-dev -y
    echo ">>>>> installed CZMQ and Zyre prerequisites"
}

# Install security packages that take a long time compiling
# python3-crypto and python3-keyrings.alt conflict with pycryptodomex.
# These packages are not included in Ubuntu 20.04.
# Removing for Ubuntu 18.04, in case it exists in the original image.
security_pkg_install() {
    sudo apt-get install apparmor-utils -y
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        sudo apt-get remove python3-crypto python3-keyrings.alt -y
    fi
    echo ">>>>> security packages setup"
}

# libgnutls30 is already installed on some architectures, but is needed for this package.
# Therefore, it is installed here to make sure it is available.
gnutls_install(){
    sudo apt-get install libgnutls30 libgnutls28-dev -y
    echo ">>>>> installed gnutls"
}

#install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2 libmsgpack-dev -y
    echo ">>>>> installed msgpack"
}

#install opendht prerequisites - expect libncurses-dev libmsgpack-dev libgnutls28-dev libasio-dev installed
#    libreadline-dev is installed on BBB and RPi, but not preinstalled on nano
opendht_prereqs_install() {
    sudo apt-get install nettle-dev libasio-dev -y
    # run liblinks script to link gnutls and msgppack for BBB only (fails for RPi)
    if [ $NODE_ARCH = "armhf" ]; then
        chmod +x /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
        PREVIOUS_PWD=$PWD
        cd /usr/lib/${ARCHINSTALL}
        sudo /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
        cd $PREVIOUS_PWD
    fi
    echo ">>>>> installed opendht prerequisites"
}

# Install capnproto prerequisites
capnproto_prereqs_install() {
    sudo apt-get install libssl-dev -y
    echo ">>>>> installed capnproto prerequisites"
}

iptables_install() {
    sudo apt-get install iptables
}


# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libcap-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libreadline-dev libsystemd-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
    sudo apt-get remove libcurl4-gnutls-dev libasio-dev -y
    sudo apt autoremove -y
    echo ">>>>> removed packages used in building process, no longer needed"
}

# Setup RIAPS repository
riaps_prereq() {
    sudo apt-get install software-properties-common apt-transport-https -y

    # Add RIAPS repository
    echo ">>>>> get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo ">>>>> add repo to sources"
    sudo add-apt-repository -r "deb [arch=${NODE_ARCH}] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" || true
    sudo add-apt-repository -n "deb [arch=${NODE_ARCH}] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main"
    sudo apt-get update
    echo ">>>>> riaps aptrepo setup"
}

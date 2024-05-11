#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-dev -y
    echo ">>>>> installed boost"
}

# install nethogs pre-requisites
nethogs_prereq_install() {
    sudo apt-get install libpcap0.8 libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    echo ">>>>> installed nethogs prerequisites"
}

# Set apt sources list grab the released packages with draft APIs
zmq_draft_apt_install() {
    if [ $LINUX_VERSION_INSTALL = "22.04" ]; then
        wget -O- https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/zeromq-archive-keyring.gpg >/dev/null
        sudo echo "deb [signed-by=/usr/share/keyrings/zeromq-archive-keyring.gpg] http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/xUbuntu_22.04/ ./" >> /etc/apt/sources.list.d/zeromq.list
    elif [ $LINUX_VERSION_INSTALL = "12" ]; then
        wget -O- https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/Debian_12/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/zeromq-archive-keyring.gpg >/dev/null
        sudo echo "deb [signed-by=/usr/share/keyrings/zeromq-archive-keyring.gpg] http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-draft/Debian_12/ ./" >> /etc/apt/sources.list.d/zeromq.list
    fi
    sudo apt-get update
    sudo apt-get install libzmq5 -y
    sudo apt-get install libzmq3-dev -y
    echo ">>>>> installed libzmq with draft APIs"
}

# libuuid1 & liblz4-1 are already installed on some architectures, but are needed for these package.
# Therefore, they are installed here to make sure they are available.
zyre_czmq_prereq_install() {
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libuuid1 liblz4-1 -y
    sudo apt-get install uuid-dev liblz4-dev -y
    sudo apt-get install pkg-config libcurl4-gnutls-dev -y
    echo ">>>>> installed libzmq, CZMQ and Zyre prerequisites"
}

# Install security packages that take a long time compiling
# python3-crypto and python3-keyrings.alt conflict with pycryptodomex.
# These packages are not included in Ubuntu 20.04.
# Removing for Ubuntu 18.04, in case it exists in the original image.
# For Ubuntu 22.04, paramiko needs bcrypt which needs rustc and cargo to install
security_pkg_install() {
    sudo apt-get install apparmor-utils -y
    if [ $LINUX_VERSION_INSTALL = "18.04" ]; then
        sudo apt-get remove python3-crypto python3-keyrings.alt -y
    elif [ $LINUX_VERSION_INSTALL = "22.04" || $LINUX_VERSION_INSTALL = "12" ]; then
        sudo apt-get install rustc cargo -y
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
    sudo apt-get install nettle-dev libasio-dev libargon2-0-dev libreadline-dev -y
    sudo apt-get install libhttp-parser-dev libjsoncpp-dev libssl-dev -y

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
    sudo apt-get install iptables -y
    echo ">>>>> installed iptables"
}

gpio_install() {
    sudo apt-get install gpiod libgpiod-dev libiio-utils -y
    echo ">>>>> installed gpio"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-dev libcap-dev libffi-dev libgnutls28-dev libncurses5-dev libncurses-dev -y
    sudo apt-get remove libsystemd-dev libmsgpack-dev libpcap-dev -y
    sudo apt-get remove uuid-dev liblz4-dev -y
    sudo apt-get remove nettle-dev libcurl4-gnutls-dev libasio-dev -y
    sudo apt-get remove libargon2-0-dev libhttp-parser-dev libjsoncpp-dev -y
    sudo apt-get remove libzmq3-dev bison -y
    sudo apt autoremove -y
    sudo pip3 uninstall cython -y
    echo ">>>>> removed packages used in building process, no longer needed"
}

# Setup RIAPS repository
riaps_prereq() {
    sudo apt-get install software-properties-common apt-transport-https -y

    # Add RIAPS repository
    wget -O- https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | gpg --dearmor | sudo tee /usr/share/keyrings/riaps-archive-keyring.gpg >/dev/null
    sudo echo "deb [arch=$NODE_ARCH signed-by=/usr/share/keyrings/riaps-archive-keyring.gpg] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" >> /etc/apt/sources.list.d/riaps.list
    sudo apt-get update
    echo ">>>>> riaps aptrepo setup"
}

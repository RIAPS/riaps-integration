#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libboost-dev:$c_arch -y
    done
    echo ">>>>> installed boost"
}

# Install nethogs pre-requisites and build with the cmake file
# Assumes libncurses6  is already installed, libncurses5-dev required by nethogs for building
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libpcap-dev:$c_arch libncurses5-dev:$c_arch -y
    done
    echo ">>>>> installed nethogs prerequisites"
}

# Install libraries for czmq and zyre, add directory for zmq compiled with draft APIs
# Use compiled is already installed
# For 20.04 & 22.04, pkg-config is already installed
zyre_czmq_prereq_install() {
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install pkg-config libcurl4-gnutls-dev -y
    # MM TODO: ran into an issue with armhf version of libcurl4-gnutls-dev, conflicts with host version (install fails)
    #          Currently not cross compiling the external libraries, so for now this is not an issue
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libsystemd-dev:$c_arch -y
        sudo apt-get install libuuid1:$c_arch liblz4-1:$c_arch -y
        #sudo apt-get install libcurl4-gnutls-dev:$c_arch -y
    done

    echo ">>>>> installed libzmq, CZMQ and Zyre prerequisites"
}

# Need to remove python3-crypto and python3-keyrings.alt due to pycryptodomex
#     install in Ubuntu 18.04
# For Ubuntu 20.04 & 22.04, python3-cryto and python3-keyrings.alt are not installed
security_prereq_install() {
    sudo apt-get install apparmor-utils -y
    if [ $LINUX_VERSION_INSTALL = "18.04" ]; then
        sudo apt-get remove python3-crypto python3-keyrings.alt -y
    fi
    echo ">>>>> installed security prerequisites"
}

# Install gnutls
# Assumes libgnutls30 is already installed
gnutls_install(){
    sudo apt-get install libgnutls28-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libgnutls30:$c_arch -y
    done
    echo ">>>>> installed gnutls"
}

# Install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2 libmsgpack-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libmsgpackc2:$c_arch -y
    done
    echo ">>>>> installed msgpack"
}

# Install opendht prerequisites
# Assumes libncurses5-dev is install (done for nethogs above)
opendht_prereqs_install() {
    sudo apt-get install libncurses5-dev -y
    sudo apt-get install nettle-dev libasio-dev libargon2-0-dev -y
    sudo apt-get install libfmt-dev libhttp-parser-dev libjsoncpp-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libncurses5-dev:$c_arch -y
        sudo apt-get install nettle-dev:$c_arch libargon2-0-dev:$c_arch -y
        sudo apt-get install libjsoncpp-dev:$c_arch -y
    done

    # run liblinks script to link gnutls and msgppack
    PREVIOUS_PWD=$PWD
    sudo chmod +x /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    for arch_tool in ${CROSS_TOOLCHAIN_LOC[@]}; do
        cd /usr/lib/$arch_tool
        sudo /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    done
    cd $PREVIOUS_PWD
    echo ">>>>> installed opendht prerequisites"
}

capnproto_prereq_install() {
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libssl-dev:$c_arch -y
    done
    echo ">>>>> installed capnproto prerequisites"s
}

gpio_install() {
    sudo apt-get install gpiod libgpiod-dev libiio-utils -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libgpiod-dev:$c_arch -y
    done
    echo ">>>>> installed gpio"
}

# Setup RIAPS repository and install script
riaps_prereq() {
    # Add RIAPS repository
    sudo touch /etc/apt/sources.list.d/riaps.list
    sudo echo "deb [arch=$HOST_ARCH] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" >> /etc/apt/sources.list.d/riaps.list
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
    sudo cp /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps_install_vm.sh /home/$RIAPSUSER/.
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_install_vm.sh
    sudo -H -u $RIAPSUSER chmod 711 /home/$RIAPSUSER/riaps_install_vm.sh
    ./riaps_install_vm.sh
    sudo apt autoremove
    echo ">>>>> riaps prerequisites installed"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo ">>>>> snap package manager removed"
}

# Install redis
redis_install () {
    if [ ! -f "/usr/local/bin/redis-server" ]; then
        wget http://download.redis.io/releases/redis-7.0.13.tar.gz
        tar xzf redis-7.0.13.tar.gz
        make -C redis-7.0.13 BUILD_TLS=yes
        sudo make -C redis-7.0.13 install
        sudo mkdir -p /etc/redis
        sudo cp redis-7.0.13/redis.conf /etc/redis/.
        rm -rf redis-7.0.13
        rm -rf redis-7.0.13.tar.gz
        echo ">>>>> installed redis"
    else
        echo ">>>>> redis already installed. skipping"
    fi
}

# Install graphical elements used by the riaps_ctrl command
graphviz_install() {
    sudo apt-get install graphviz xdot -y
    echo ">>>>> installed graphviz"
}

#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libboost-dev:$c_arch -y
    done
    echo ">>>>> installed boost"
}

# Install nethogs pre-requisites
# Assumes libncurses6  is already installed
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libpcap-dev:$c_arch -y
    done
    echo ">>>>> installed nethogs prerequisites"
}

# Install libraries for czmq and zyre
# Assumes libzmq5 is already installed
# For 20.04, pkg-config is already installed
zyre_czmq_prereq_install() {
    sudo apt-get install libzmq3-dev -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install pkg-config libcurl4-gnutls-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libzmq3-dev:$c_arch -y
        sudo apt-get install libsystemd-dev:$c_arch -y
        sudo apt-get install libuuid1:$c_arch liblz4-1:$c_arch -y
    done
    echo ">>>>> installed CZMQ and Zyre prerequisites"
}

# Need to remove python3-crypto and python3-keyrings.alt due to pycryptodomex
#     install in Ubuntu 18.04
# For Ubuntu 20.04, python3-cryto and python3-keyrings.alt are not installed
security_prereq_install() {
    sudo apt-get install apparmor-utils -y
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
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
    sudo apt-get install nettle-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libncurses5-dev:$c_arch -y
        sudo apt-get install nettle-dev:$c_arch -y
    done

    # run liblinks script to link gnutls and msgppack
    PREVIOUS_PWD=$PWD
    chmod +x /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    for arch_tool in ${CROSS_TOOLCHAIN_LOC[@]}; do
        cd /usr/lib/$arch_tool
        sudo /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
    done
    cd $PREVIOUS_PWD
    echo ">>>>> installed opendht prerequisites"
}

# Setup RIAPS repository and install script
riaps_prereq() {
    # Add RIAPS repository
    sudo add-apt-repository -r "deb [arch=$HOST_ARCH] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
    sudo cp /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps_install_vm.sh /home/$RIAPSUSER/.
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_install_vm.sh
    sudo -H -u $RIAPSUSER chmod 711 /home/$RIAPSUSER/riaps_install_vm.sh
    #./riaps_install_vm.sh
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
        wget http://download.redis.io/releases/redis-6.2.1.tar.gz
        tar xzf redis-6.2.1.tar.gz
        make -C redis-6.2.1 BUILD_TLS=yes
        sudo make -C redis-6.2.1 install
        sudo mkdir -p /etc/redis
        sudo cp redis.conf /etc/redis
        rm -rf redis-6.2.1
        rm -rf redis-6.2.1.tar.gz
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

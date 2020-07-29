#!/usr/bin/env bash
set -e

boost_install() {
    sudo apt-get install libboost-dev -y
    sudo apt-get install libboost-dev:armhf libboost-dev:arm64 -y
    echo ">>>>> installed boost"
}

# install nethogs pre-requisites
# Assumes libncurses6  is already installed
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libpcap-dev:armhf libpcap-dev:arm64 -y
    sudo apt-get install libncurses5-dev -y
    echo ">>>>> installed nethogs prerequisites"
}

#install libraries for czmq and zyre
# Assumes libzmq5 and pkg-config are already installed
zyre_czmq_prereq_install() {
    sudo apt-get install libzmq3-dev -y
    sudo apt-get install libzmq3-dev:armhf libzmq3-dev:arm64 -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libsystemd-dev:armhf libsystemd-dev:arm64 -y
    sudo apt-get install libuuid1:armhf liblz4-1:armhf -y
    sudo apt-get install libuuid1:arm64 liblz4-1:arm64 -y
    sudo apt-get install pkg-config -y
    echo ">>>>> installed CZMQ and Zyre prerequisites"
}

# Need to remove python3-crypto and python3-keyrings.alt due to pycryptodomex install
security_prereq_install() {
    sudo apt-get install apparmor-utils -y
    sudo apt-get remove python3-crypto python3-keyrings.alt -y
    echo ">>>>> installed security prerequisites"
}

# install gnutls
# Assumes libgnutls30 is already installed
gnutls_install(){
    sudo apt-get install libgnutls30:armhf libgnutls30:arm64 -y
    sudo apt-get install libgnutls28-dev -y
    echo ">>>>> installed gnutls"
}

#install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2:amd64 -y
    sudo apt-get install libmsgpackc2:armhf libmsgpackc2:arm64 -y
    sudo apt-get install libmsgpack-dev:amd64 -y
    sudo apt-get install libmsgpackc2 libmsgpack-dev -y
    echo ">>>>> installed msgpack"
}

#install opendht prerequisites
# Assumes libncurses5-dev is install (done for nethogs above)
opendht_prereqs_install() {
    sudo apt-get install libncurses5-dev -y
    sudo apt-get install libncurses5-dev:armhf libncurses5-dev:arm64 -y
    sudo apt-get install nettle-dev -y
    sudo apt-get install nettle-dev:armhf nettle-dev:arm64 -y
    # run liblinks script to link gnutls and msgppack
    PREVIOUS_PWD=$PWD
    chmod +x /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    cd /usr/lib/arm-linux-gnueabihf
    sudo /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    cd /usr/lib/aarch64-linux-gnu
    sudo /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    cd $PREVIOUS_PWD
    echo ">>>>> installed opendht prerequisites"
}

riaps_prereq() {
   # Add RIAPS repository
   sudo add-apt-repository -r "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main" || true
   sudo add-apt-repository -n "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main"
   wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
   sudo apt-get update
   sudo cp /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps_install_amd64.sh /home/$1/.
   sudo chown $1:$1 /home/$1/riaps_install_amd64.sh
   sudo -H -u $1 chmod 711 /home/$1/riaps_install_amd64.sh
   #./riaps_install_amd64.sh
   echo ">>>>> riaps prerequisites installed"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo ">>>>> snap package manager removed"
}

# install redis
redis_install () {
   if [ ! -f "/usr/local/bin/redis-server" ]; then
    wget http://download.redis.io/releases/redis-4.0.11.tar.gz
    tar xzf redis-4.0.11.tar.gz
    make -C redis-4.0.11
    sudo make -C redis-4.0.11 install
    rm -rf redis-4.0.11
    rm -rf redis-4.0.11.tar.gz
    echo ">>>>> installed redis"
   else
     echo ">>>>> redis already installed. skipping"
   fi
}

graphviz_install() {
    sudo apt-get install graphviz xdot -y
    echo ">>>>> installed graphviz"
}

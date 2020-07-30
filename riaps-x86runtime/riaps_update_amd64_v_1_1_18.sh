#!/usr/bin/env bash

source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`
    do
        source "$PWD/$SCRIPTS/$i"
    done
    echo ">>>>> sourced install scripts"
}


set -e

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# For v1.1.18, riaps-pycom riaps.conf and riaps-log.conf files have been update
# it is best to remove the riaps-pycom-amd64 package completely and then reinstall
# Remember to update the nic name for /etc/riaps.conf after installation
sudo apt-get purge riaps-pycom-amd64 || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-amd64 riaps-pycom-amd64 riaps-timesync-amd64 -y

# new packages installed/removed
source_scripts

rm_snap_pkg

#Updates needed - but need to program with new script calls
#cross_setup
   sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse" || true
   sudo add-apt-repository -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse"

   sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse" || true
   sudo add-apt-repository  -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse"

    sudo dpkg --add-architecture arm64
    sudo apt-get install crossbuild-essential-arm64 -y

#cmake_func
    sudo apt-get install libreadline-dev:arm64 -y

#python_install
    sudo apt-get install libpython3-dev:arm64 -y

#externals_cmake_install
    PREVIOUS_PWD=$PWD
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cmake -Darch=arm64 ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cd $PREVIOUS_PWD

#boost_install
    sudo apt-get install libboost-dev:arm64 -y

#nethogs_prereq_install
    sudo apt-get install libpcap-dev:arm64 -y

#zyre_czmq_prereq_install
    sudo apt-get install libzmq3-dev:arm64 -y
    sudo apt-get install libsystemd-dev:arm64 -y
    sudo apt-get install libuuid1:arm64 liblz4-1:arm64 -y

#gnutls_install
    sudo apt-get install libgnutls30:arm64 -y

#msgpack_install
    sudo apt-get install libmsgpackc2:arm64 -y

#opendht_prereqs_install
    sudo apt-get install libncurses5-dev:arm64 -y
    sudo apt-get install nettle-dev:arm64 -y

#other_pip3_installs
    sudo pip3 install 'paramiko==2.7.1' 'cryptography==2.9.2'
    sudo pip3 install --ignore-installed 'PyYAML==5.1.1'
    sudo pip3 install 'gitpython==3.1.7'

#prctl_install for 18.04
    sudo apt-get install libcap-dev -y
    pip3 install 'python-prctl==1.7'
}

#prctl_install for 20.04
sudo apt-get install libcap-dev -y
git clone http://github.com/seveas/python-prctl
cd python-prctl/
python3 setup.py build
sudo python3 setup.py install

#update the bbb_initial_keys folder to be riaps_initial_keys

echo "installed RIAPS platform"

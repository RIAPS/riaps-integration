#!/usr/bin/env bash
set -e

# Configure for cross functional compilation - this is vagrant box config dependent
cross_setup() {
    sudo apt-get install apt-transport-https -y

    echo ">>>>> add amd64, i386"
    # Qualify the architectures for existing repositories
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic  multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security main restricted"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security universe"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security multiverse"

    echo ">>>>> add armhf, arm64"
    # Add armhf repositories
    sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse"

    sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse" || true
    sudo add-apt-repository  -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse"

    echo ">>>>> updated sources.list for multiarch"

    sudo dpkg --add-architecture armhf
    sudo dpkg --add-architecture arm64
    sudo apt-get update
    echo ">>>>> packages update complete for multiarch"
    sudo apt-get install crossbuild-essential-armhf crossbuild-essential-arm64 gdb-multiarch -y
    sudo apt-get install build-essential -y
    echo ">>>>> setup multi-arch capabilities complete"
}

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    sudo apt-get install libreadline-dev:armhf libreadline-dev:arm64 -y
    echo ">>>>> installed cmake"
}

python_install() {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip -y
    sudo apt-get install libpython3-dev:armhf libpython3-dev:arm64 -y
    sudo pip3 install --upgrade pip
    echo ">>>>> installed python3"
}

# Assumes that Cython3 is not on the base release (18.04.3 does not have it)
cython_install() {
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.28.5' --verbose
    echo ">>>>> installed cython"
}

curl_func() {
    sudo apt install curl -y
    echo ">>>>> installed curl"
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    cmake -Darch=amd64 ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    cmake -Darch=armhf ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cmake -Darch=arm64 ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cd $PREVIOUS_PWD
    echo ">>>>> cmake install complete"
}

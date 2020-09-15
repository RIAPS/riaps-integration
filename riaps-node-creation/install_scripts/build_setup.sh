#!/usr/bin/env bash
set -e

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    echo ">>>>> installed cmake"
}

# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip -y
    sudo pip3 install --upgrade pip
    sudo pip3 install pydevd
    echo ">>>>> installed python3 and pydev"
}

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
    mkdir -p /tmp/3rdparty/build
    cp CMakeLists.txt /tmp/3rdparty/.
    cd /tmp/3rdparty/build
    cmake -Darch=${NODE_ARCH} ..
    make
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/
    echo ">>>>> cmake install complete"
}

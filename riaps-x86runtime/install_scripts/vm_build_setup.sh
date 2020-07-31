#!/usr/bin/env bash
set -e

# Configure for cross functional compilation - this is vagrant box config dependent
cross_setup() {
    sudo apt-get install apt-transport-https -y

    echo ">>>>> add host architecture"

    # Qualify the architectures for existing repositories
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO main restricted" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates main restricted" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO universe" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates universe" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO  multiverse" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates multiverse" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-backports main restricted universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-backports main restricted universe multiverse"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security main restricted" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security main restricted"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security universe" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security universe"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security multiverse" || true
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security multiverse"

    echo ">>>>> add cross compile architectures"

    i=0
    DELIM=","
    for c_arch in ${ARCHS_CROSS[@]}; do
        if [ $i = 0 ]; then
            all_carchs="$c_arch"
        else
            all_carchs="$all_carchs$DELIM$c_arch"
        fi
        i=$((i+1))

        sudo dpkg --add-architecture $c_arch
    done

    sudo add-apt-repository -r "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO main universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO main universe multiverse"

    sudo add-apt-repository -r "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO-updates main universe multiverse" || true
    sudo add-apt-repository  -n "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO-updates main universe multiverse"

    sudo cat /etc/apt/sources.list
    echo ">>>>> updated sources.list for multiarch"

    sudo apt-get update
    echo ">>>>> packages update complete for multiarch"
    sudo apt-get install gdb-multiarch build-essential -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install crossbuild-essential-$c_arch -y
    done
    echo ">>>>> setup multi-arch capabilities complete"
}

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libreadline-dev:$c_arch -y
    done
    echo ">>>>> installed cmake"
}

python_install() {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libpython3-dev:$c_arch -y
    done
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

    # Host architecture
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$HOST_ARCH
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$HOST_ARCH
    cmake -Darch=$HOST_ARCH ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$HOST_ARCH

    # Cross compile architecture
    for c_arch in ${ARCHS_CROSS[@]}; do
        mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$c_arch
        cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$c_arch
        cmake -Darch=$c_arch ..
        make
        cd /home/riapsadmin/riaps-integration/riaps-x86runtime
        rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-$c_arch
    done

    cd $PREVIOUS_PWD
    echo ">>>>> cmake install complete"
}

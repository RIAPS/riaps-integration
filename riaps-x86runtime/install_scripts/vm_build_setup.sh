#!/usr/bin/env bash
set -e

# Configure for cross functional compilation - this is xubuntu release config dependent
cross_setup() {
    sudo apt-get install apt-transport-https -y

    echo ">>>>> add host architecture"
    # Qualify the architectures for existing repositories
    add_host_arch_apt_repos

    echo ">>>>> add cross compile architectures"
    add_cross_compile_archs

    sudo cat /etc/apt/sources.list
    echo ">>>>> updated sources.list for multiarch"

    sudo apt-get update
    echo ">>>>> packages update complete for multiarch"
    sudo apt-get install gdb-multiarch build-essential -y
    add_cross_compile_buildtools
    echo ">>>>> setup multi-arch capabilities complete"
}

add_host_arch_apt_repos() {
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
}


# Add cross compile architectures to the VM setup
add_cross_compile_archs(){
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
}

# Add the cross compile build tools for the foreign architectures
add_cross_compile_buildtools(){
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install crossbuild-essential-$c_arch -y
    done
}

# Install tools needed to build external third party tools needed for RIAPS
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

# Install pip3 and python development tools
python_install() {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip python-is-python3 -y
    if [ $LINUX_VERSION_INSTALL = "22.04" ]; then
        sudo apt-get install python3.10-venv -y
    else
        sudo apt-get install python3.8-venv -y
    fi
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libpython3-dev:$c_arch -y
    done
    sudo pip3 install --upgrade pip
    echo ">>>>> installed python3"
}

# Assumes that Cython3 is not on the base release (18.04.3 does not have it)
cython_install() {
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.29.32' --verbose
    echo ">>>>> installed cython"
}

curl_func() {
    sudo apt-get install curl -y
    echo ">>>>> installed curl"
}

# Install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD

    # Host architecture
    externals_cmake_build $HOST_ARCH $LINUX_VERSION_INSTALL
    cd $PREVIOUS_PWD
    echo ">>>>> cmake install complete"
}


externals_cmake_build(){
    mkdir -p /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cd /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cmake -Darch=$1 -Dubuntu_rel=$2 ..
    make
    cd /home/$INSTALL_USER$INSTALL_SCRIPT_LOC
    rm -rf /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
}

# Configure gcc setup when multiple versions available
config_gcc() {
    if [ $LINUX_VERSION_INSTALL = "18.04"]; then
        sudo apt-get install gcc-7 g++-7 -y

        # Setup GCC-7 as default in all architectures
        # Host architecture
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
        sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
        sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
        sudo update-alternatives --set gcc /usr/bin/gcc-7
        sudo update-alternatives --set g++ /usr/bin/g++-7
        gcc --version
        g++ --version
    elif [ $LINUX_VERSION_INSTALL = "20.04" ]; then
        sudo apt-get install gcc-9 g++-9 -y
    elif [ $LINUX_VERSION_INSTALL = "22.04" ]; then
        sudo apt-get install gcc-10 g++-10 -y
    fi

    # Cross compile architectures
    for c_arch in ${ARCHS_CROSS[@]}; do
        if [ $LINUX_VERSION_INSTALL = "18.04"]; then
            sudo apt-get install gcc-7:$c_arch g++-7:$c_arch -y
        elif [ $LINUX_VERSION_INSTALL = "20.04" ]; then
            sudo apt-get install gcc-9:$c_arch g++-9:$c_arch -y
        elif [ $LINUX_VERSION_INSTALL = "22.04" ]; then
            sudo apt-get install gcc-10:$c_arch g++-10:$c_arch -y
        fi
    done

    for c_arch_tool in ${CROSS_TOOLCHAIN_LOC[@]}; do
        if [ $LINUX_VERSION_INSTALL = "18.04"]; then
            sudo update-alternatives --install /usr/bin/$c_arch_tool-gcc gcc /usr/bin/$c_arch_tool-gcc-7 7
            sudo update-alternatives --install /usr/bin/$c_arch_tool-gcc gcc /usr/bin/$c_arch_tool-gcc-9 9
            sudo update-alternatives --install /usr/bin/$c_arch_tool-g++ g++ /usr/bin/$c_arch_tool-g++-7 7
            sudo update-alternatives --install /usr/bin/$c_arch_tool-g++ g++ /usr/bin/$c_arch_tool-g++-9 9
            sudo update-alternatives --set gcc /usr/bin/$c_arch_tool-gcc-7
            sudo update-alternatives --set g++ /usr/bin/$c_arch_tool-g++-7
            $c_arch_tool-gcc --version
            $c_arch_tool-g++ --version
        fi
    done

    echo "configured gcc/g++"
}

configure_library_path() {
    sudo touch /etc/ld.so.conf.d/riaps.conf
    sudo echo "# Add RIAPS Library for ZeroMQ specific builds" >> /etc/ld.so.conf.d/riaps.conf
    sudo echo "$RIAPS_PREFIX/lib" >> /etc/ld.so.conf.d/riaps.conf
    sudo ldconfig
}
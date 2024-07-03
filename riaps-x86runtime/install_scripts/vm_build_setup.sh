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
    sudo apt-get install gdb-multiarch build-essential binutils-multiarch -y
    add_cross_compile_buildtools
    echo ">>>>> setup multi-arch capabilities complete"
}

add_host_arch_apt_repos() {
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO main restricted" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO main restricted" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates main restricted" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates main restricted" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO universe" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO universe" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates universe" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates universe" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO  multiverse" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO multiverse" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates multiverse" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-updates multiverse" -y

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-backports main restricted universe multiverse" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://us.archive.ubuntu.com/ubuntu/ $CURRENT_PACKAGE_REPO-backports main restricted universe multiverse" -y

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security main restricted" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security main restricted" -y

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security universe" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security universe" -y

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security multiverse" -y
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] http://security.ubuntu.com/ubuntu $CURRENT_PACKAGE_REPO-security multiverse" -y
}

add_host_arch_apt_repos_deb822(){
    # Move preconfigured ubuntu.sources file to system (/etc/apt/sources.list.d/ubuntu.sources)
    sudo cp /etc/apt/sources.list.d/ubuntu.sources ubuntu.sources.old
    sudo cp vm_ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
    sudo systemctl daemon-reload
    sudo apt-get update
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

    sudo add-apt-repository -r "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO main universe multiverse" -y
    sudo add-apt-repository -n "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO main universe multiverse" -y

    sudo add-apt-repository -r "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO-updates main universe multiverse" -y
    sudo add-apt-repository  -n "deb [arch=$all_carchs] http://ports.ubuntu.com/ubuntu-ports $CURRENT_PACKAGE_REPO-updates main universe multiverse" -y
}

# Add the cross compile build tools for the foreign architectures
add_cross_compile_buildtools(){
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install crossbuild-essential-$c_arch -y
    done
}

# Install tools needed to build external third party tools needed for RIAPS
cmake_func() {
    sudo apt-get install cmake bison -y
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
    sudo apt-get install python3-pkgconfig -y
    if [ $LINUX_VERSION_INSTALL = "24.04" ]; then
        sudo apt-get install python3.12-venv -y
    elif [ $LINUX_VERSION_INSTALL = "22.04" ]; then
        sudo apt-get install python3.10-venv -y
    else
        sudo apt-get install python3.8-venv -y
    fi
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libpython3-dev:$c_arch -y
    done
    #MM TODO: adding --break-system-packages does not work here, don't upgrade for now
    #sudo pip3 install --upgrade pip
    echo ">>>>> installed python3"
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
    externals_cmake_build $HOST_ARCH
    sudo ldconfig
    cd $PREVIOUS_PWD
    echo ">>>>> cmake install complete"
}


externals_cmake_build(){
    mkdir -p /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cd /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cmake -Darch=$1 ..
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
        sudo apt-get install gcc-11 g++-11 -y
    fi

    # Cross compile architectures
    # MM TODO:  This step (in 22.04) removes cross build tools, not sure this is still needed
    #for c_arch in ${ARCHS_CROSS[@]}; do
    #    if [ $LINUX_VERSION_INSTALL = "18.04"]; then
    #        sudo apt-get install gcc-7:$c_arch g++-7:$c_arch -y
    #    elif [ $LINUX_VERSION_INSTALL = "20.04" ]; then
    #        sudo apt-get install gcc-9:$c_arch g++-9:$c_arch -y
    #    elif [ $LINUX_VERSION_INSTALL = "22.04" ]; then
    #        sudo apt-get install gcc-11:$c_arch g++-11:$c_arch -y
    #    fi
    #done

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

    echo ">>>>> configured gcc/g++"
}

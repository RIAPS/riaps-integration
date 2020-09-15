#!/usr/bin/env bash
set -e

spdlog_python_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/spdlog-python.git $TMP/spdlog-python
    cd $TMP/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed spdlog"
}

apparmor_monkeys_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/apparmor_monkeys.git $TMP/apparmor_monkeys
    cd $TMP/apparmor_monkeys
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed apparmor_monkeys"
}

pyzmq_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/pyzmq.git $TMP/pyzmq
    cd $TMP/pyzmq
    git checkout v17.1.2
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed pyzmq"
}

# Install bindings for czmq. Must be run after pyzmq, czmq install.
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq_pybindings
    cd $TMP/czmq_pybindings/bindings/python
    git checkout 9ee60b18e8bd8ed4adca7fdaff3e700741da706e
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed CZMQ pybindings"
}

# Install bindings for zyre. Must be run after zyre, pyzmq install.
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre_pybindings
    cd $TMP/zyre_pybindings/bindings/python
    git checkout b36470e70771a329583f9cf73598898b8ee05d14
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed Zyre pybindings"
}

# Link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3' --verbose
    echo ">>>>> linked pycapnp with capnproto"
}

# Install prctl package
prctl_install() {
    sudo apt-get install libcap-dev -y
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/python-prctl.git $TMP/python-prctl
    cd $TMP/python-prctl/
    git checkout feature-ambient
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed prctl"
}

# Installing butter
# For Python 3.8 (used in Ubuntu 20.04), butter does not install with pip
butter_install() {
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        pip3 install 'butter==0.12.6' --verbose
    else
        # This project is a fork of butter located at http://blitz.works/butter/file/tip at version 0.12.6.
        PREVIOUS_PWD=$PWD
        TMP=`mktemp -d`
        git clone https://github.com/RIAPS/butter.git $TMP/butter
        cd $TMP/butter
        sudo python3 setup.py install
        cd $PREVIOUS_PWD
        rm -rf $TMP
    fi
    echo ">>>>> installed butter"
}

# Install other required packages
pip3_3rd_party_installs(){
    pip3 install 'pydevd==1.8.0' 'rpyc==4.1.5' 'redis==2.10.6' 'hiredis == 0.2.0' 'netifaces==0.10.7' 'cgroups==0.1.0' 'cgroupspy==0.1.6' 'lmdb==0.94' 'fabric3==1.14.post1' 'pyroute2==0.5.2' 'minimalmodbus==0.7' 'pyserial==3.4' 'pybind11==2.2.4' 'toml==0.10.0' 'pycryptodomex==3.7.3' --verbose
    # Ubuntu 20.04 (and 18.04.4) uses Python 3.8.
    # Python 3.8 has this installed already, need to overwrite
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        pip3 install 'psutil==5.7.0' --verbose
    else
        pip3 install --ignore-installed 'psutil==5.7.0' --verbose
    fi

    # Package in distro already, leaving it in site-packages
    pip3 install --ignore-installed 'PyYAML==5.1.1'
    echo ">>>>> installed pip3 packages"
}

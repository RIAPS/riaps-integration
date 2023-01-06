#!/usr/bin/env bash
set -e

# Install spdlog python logger
spdlog_python_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/spdlog-python.git $TMP/spdlog-python
    cd $TMP/spdlog-python
    git clone -b v1.10.0 --depth 1 https://github.com/gabime/spdlog.git
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
    git checkout v23.2.1
    sudo pip3 install . --verbose
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
    git checkout v4.2.1
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
    git checkout v2.0.1
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed Zyre pybindings"
}

# Link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    sudo pip3 install pkgconfig --verbose
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==1.0.0' --verbose
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
# using the forked project for now since it has the desired setup.py fix ("platforms=[]"), need to update the fork when changing versions later
# MM TODO (9/20/22) - going to try pip package again, this may not be needed anymore
butter_install() {
    pip3 install 'cffi==1.15.0' --verbose
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

# Installing rpyc
# MM removing, latest package is pypi now
rpyc_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/tomerfiliba-org/rpyc $TMP/rpyc
    cd $TMP/rpyc
    git checkout 5.2.3
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf $TMP/rpyc
}

py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jnwatson/py-lmdb.git $TMP/py_lmdb
    cd $TMP/py_lmdb
    git checkout py-lmdb_1.3.0
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf $TMP/py_lmdb
}

# Install other required packages
pip3_3rd_party_installs(){
    pip3 install 'pydevd==2.8.0' 'redis==4.3.4' 'hiredis==2.0.0' 'netifaces==0.11.0' --verbose
    pip3 install 'bcrypt==3.2.2' 'paramiko==2.11.0' 'cryptography==3.3.2' 'cgroups==0.1.0' 'cgroupspy==0.2.2' --verbose
    pip3 install 'fabric3==1.14.post1' 'pyroute2==0.7.2' 'pyserial==3.5' --verbose
    pip3 install 'pybind11==2.10.0' 'toml==0.10.2' 'pycryptodomex==3.15.0' --verbose
    pip3 install 'psutil==5.9.2' 'rpyc==5.2.3' --verbose
    pip3 install 'parse==1.19.0' 'butter==0.13.1' --verbose
    pip3 install 'gpiod==1.5.3' --verbose
    # Use a newer version than distribution installed
    # Python 3.8 has this installed already, need to overwrite 
    pip3 install --ignore-installed 'PyYAML==6.0' --verbose
    echo ">>>>> installed pip3 packages"
}

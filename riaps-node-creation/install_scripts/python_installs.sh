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
    git checkout v22.0.3
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
rpyc_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/tomerfiliba-org/rpyc $TMP/rpyc
    cd $TMP/rpyc
    git checkout 5.0.1
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf $TMP/rpyc
}

py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jnwatson/py-lmdb.git $TMP/py_lmdb
    cd $TMP/py_lmdb
    git checkout py-lmdb_1.1.1
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf $TMP/py_lmdb
}

# Install other required packages
pip3_3rd_party_installs(){
    pip3 install 'pydevd==2.8.0' 'redis==3.5.3' 'hiredis==1.1.0' 'netifaces==0.11.0' --verbose
    pip3 install 'bcrypt==3.2.0' 'paramiko==2.7.2' 'cryptography==2.8' 'cgroups==0.1.0' 'cgroupspy==0.1.6' --verbose
    pip3 install 'fabric3==1.14.post1' 'pyroute2==0.5.14' 'pyserial==3.5' --verbose
    pip3 install 'pybind11==2.10.0' 'toml==0.10.2' 'pycryptodomex==3.10.1' --verbose
    pip3 install 'psutil==5.5.1' 'parse==1.19.0' --verbose

    # Ubuntu 20.04 (and 18.04.4) uses Python 3.8.
    # Python 3.8 has this installed already, need to overwrite for 18.04
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        pip3 install --ignore-installed 'PyYAML==5.3.1' --verbose
    else
        pip3 install 'PyYAML==5.3.1' --verbose
    fi
    echo ">>>>> installed pip3 packages"
}

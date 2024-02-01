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
    git checkout v25.1.2
    ZMQ_DRAFT_API=1 sudo -E pip install -v --no-binary pyzmq --pre pyzmq
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
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/capnproto/pycapnp.git $TMP/pycapnp
    cd $TMP/pycapnp
    git checkout v2.0.0b2
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
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

# Install dependencies: libffi-dev (already as part of timesync requirements), python-dev build-essential
# Should be called after cross_setup and timesync_requirements functions
py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jnwatson/py-lmdb.git $TMP/python-lmdb
    cd $TMP/python-lmdb/
    git checkout py-lmdb_1.4.1
    sudo -E pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> installed lmdb"
}

cython_install() {
    pip3 install Cython --verbose
    echo ">>>>> installed cython"
}

# Install other required packages
# base install should already have PyYAML==5.3.1
# Utilizing distribution installed
#     For 20.04: pyyaml = 5.3.1, psutil = 5.5.1 
#     For 22.04: pyyaml = 5.4.1, cryptography = 3.4.8, netifaces = 0.11.0
# Since python installs needing Cython typically calls for the latest version, do not specify a version for this package
pip3_3rd_party_installs(){
    pip3 install 'redis==5.0.1' 'hiredis==2.3.2' --verbose
    pip3 install 'pydevd==2.9.6' 'netifaces2==0.0.19' --verbose
    pip3 install 'cgroups==0.1.0' 'cgroupspy==0.2.2' --verbose
    pip3 install 'pyroute2==0.7.9' 'pyserial==3.5' --verbose
    pip3 install 'pybind11==2.11.1' 'toml==0.10.2' 'pycryptodomex==3.19.0' --verbose
    pip3 install 'rpyc==5.3.1' 'parse==1.19.1' 'butter==0.13.1' --verbose
    pip3 install 'gpiod==1.5.4', 'spdlog==2.0.6' --verbose
    if [ $LINUX_VERSION_INSTALL = "22.04" ]; then
        pip3 install 'psutil==5.9.0' --verbose
    fi
    pip3 install 'paramiko==3.4.0' 'cryptography==3.4.8' --verbose
    pip3 install 'fabric2==3.2.2' --verbose
    echo ">>>>> installed pip3 packages"
}

#!/usr/bin/env bash
set -e


# Install apparmor_monkeys
apparmor_monkeys_install(){
    PREVIOUS_PWD=$PWD
    git clone https://github.com/RIAPS/apparmor_monkeys.git /tmp/3rdparty/apparmor_monkeys
    cd /tmp/3rdparty/apparmor_monkeys
    python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/apparmor_monkeys
    echo ">>>>> installed apparmor_monkeys"
}

pyzmq_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/zeromq/pyzmq.git
    cd /tmp/3rdparty/pyzmq
    git checkout v23.2.1
    ZMQ_DRAFT_API=1 ZMQ_PREFIX=$RIAPS_PREFIX sudo -E pip install . -v --no-binary pyzmq --pre pyzmq --verbose
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/pyzmq
    echo ">>>>> installed pyzmq"
}

# Install bindings for czmq. Must be run after pyzmq, czmq install.
# Code was pulled for external cmake build and is the correct branch prior to this call
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/czmq-$HOST_ARCH/bindings/python
    ZMQ_PREFIX=$RIAPS_PREFIX sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed CZMQ pybindings"
}

# Install bindings for zyre. Must be run after zyre, pyzmq install.
# Code was pulled for external cmake build and is the correct branch prior to this call
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/zyre-$HOST_ARCH/bindings/python
    ZMQ_PREFIX=$RIAPS_PREFIX sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed Zyre pybindings"
}

# Link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install(){
    sudo pip3 install pkgconfig
    #if [ $LINUX_VERSION_INSTALL = "22.04" ]; then
    #    sudo pip3 install 'pycapnp==1.0.0' --verbose
    #else
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib sudo pip3 install 'pycapnp==1.2.2' --verbose
    #fi
    echo ">>>>> linked pycapnp with capnproto"
}

# Install prctl package
prctl_install(){
    sudo apt-get install libcap-dev -y
    for c_arch in ${ARCHS_CROSS[@]}; do
        sudo apt-get install libcap-dev:$c_arch -y
    done

    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/RIAPS/python-prctl.git /tmp/3rdparty/python-prctl
    cd /tmp/3rdparty/python-prctl
    git checkout feature-ambient
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/python-prctl

    echo ">>>>> installed prctl"
}

# Installing py-lmdb
py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/jnwatson/py-lmdb.git /tmp/3rdparty/py_lmdb
    cd /tmp/3rdparty/py_lmdb
    git checkout py-lmdb_1.3.0
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/py_lmdb
    echo ">>>>> installed lmdb"
}

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

# Install other required packages
# Ubuntu 20.04 comes with PyYAML==5.3.1 and psutil==5.5.1
# Ubuntu 22.04 comes with netinterfaces==0.11.0, cryptography==3.4.8, PyYAML==5.4.1 and psutil==5.9.0
# MM TODO: consider adding 'requests==2.31.0' - seeing conflict with urllib3 version requirements between this and influxdb-client,
#          not sure which packages is asking for request at version 2.22.0 right now (investigate later)
pip3_3rd_party_installs(){
    pip3 install 'pydevd==2.9.6' 'redis==4.6.0' 'hiredis==2.2.3' 'netifaces==0.11.0' --verbose
    pip3 install 'bcrypt==4.0.1' 'paramiko==3.3.1' 'cryptography==3.4.8' 'cgroups==0.1.0' 'cgroupspy==0.2.2' --verbose
    pip3 install 'fabric2==3.2.2' 'pyroute2==ß0.7.9' 'pyserial==3.5' --verbose
    pip3 install 'pybind11==2.11.1' 'toml==0.10.2' 'pycryptodomex==3.19.0' --verbose
    pip3 install 'rpyc==5.3.1' 'parse==1.19.1' 'butter==0.13.1' --verbose
    pip3 install 'gpiod==1.5.4', 'spdlog==2.0.6' --verbose

    # VM Only packages
    pip3 install 'textX==3.1.1' 'pydot==1.4.2' 'gitpython==3.1.37' 'pymultigen==0.2.0' 'Jinja2==3.1.2' --verbose
    pip3 install 'libtmux==0.23.2' 'graphviz==0.20.1' 'python-magic==0.4.27' 'influxdb-client==1.37.0' --verbose
    echo ">>>>> installed pip3 packages"
}

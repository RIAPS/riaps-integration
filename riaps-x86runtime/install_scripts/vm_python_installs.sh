#!/usr/bin/env bash
set -e

# Install spdlog python logger
# No longer using this (remove once tested)
spdlog_python_install(){
    PREVIOUS_PWD=$PWD
    git clone https://github.com/RIAPS/spdlog-python.git /tmp/3rdparty/spdlog-python
    cd /tmp/3rdparty/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/spdlog-python
    echo ">>>>> installed spdlog python"
}

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

#MM TODO:  this did not install when the script ran - ran manually
pyzmq_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/zeromq/pyzmq.git
    cd /tmp/3rdparty/pyzmq
    git checkout v22.0.3
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/pyzmq
    echo ">>>>> installed pyzmq"
}

# Install bindings for czmq. Must be run after pyzmq, czmq install.
# Code was pulled for external cmake build and is the correct branch prior to this call
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/czmq-$HOST_ARCH/bindings/python
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed CZMQ pybindings"
}

# Install bindings for zyre. Must be run after zyre, pyzmq install.
# Code was pulled for external cmake build and is the correct branch prior to this call
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/zyre-$HOST_ARCH/bindings/python
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed Zyre pybindings"
}

# Link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install(){
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==1.0.0' --verbose
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

# Installing butter
# For 20.04, butter does not install with pip
# using the forked project for now since it has the desired setup.py fix ("platforms=[]"), need to update the fork when changing versions later
butter_install() {
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        pip3 install 'butter==0.12.6' --verbose
    else
        # This project is a fork of butter located at http://blitz.works/butter/file/tip at version 0.12.6.
        PREVIOUS_PWD=$PWD
        cd /tmp/3rdparty
        git clone https://github.com/RIAPS/butter.git /tmp/3rdparty/butter
        cd /tmp/3rdparty/butter
        sudo python3 setup.py install
        cd $PREVIOUS_PWD
        rm -rf /tmp/3rdparty/butter
    fi
    echo ">>>>> installed butter"
}

# Installing rpyc
rpyc_install() {
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/tomerfiliba-org/rpyc /tmp/3rdparty/rpyc
    cd /tmp/3rdparty/rpyc
    git checkout 5.0.1
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/rpyc
}

# Installing py-lmdb
py_lmdb_install() {
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/jnwatson/py-lmdb.git /tmp/3rdparty/py_lmdb
    cd /tmp/3rdparty/py_lmdb
    git checkout py-lmdb_1.1.1
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/py_lmdb
}


# Install other required packages
pip3_3rd_party_installs(){
    pip3 install 'pydevd==2.3.0' 'redis==3.5.3' 'hiredis==1.1.0' 'netifaces==0.10.7' --verbose
    pip3 install 'paramiko==2.7.2' 'cryptography==2.8' 'cgroups==0.1.0' 'cgroupspy==0.1.6' --verbose
    pip3 install 'fabric3==1.14.post1' 'pyroute2==0.5.14' 'minimalmodbus==0.7' 'pyserial==3.4' --verbose
    pip3 install 'pybind11==2.6.2' 'toml==0.10.2' 'pycryptodomex==3.10.1' 'spdlog==2.0.4' --verbose
    pip3 install 'Adafruit_BBIO==1.2.0' --verbose
    pip3 install 'parse==1.19.0' --verbose

    # Ubuntu 20.04 (and 18.04.4) uses Python 3.8.
    # Python 3.8 has this installed already, need to overwrite for 18.04
    if [ $UBUNTU_VERSION_INSTALL = "18.04" ]; then
        pip3 install 'psutil==5.5.1' --verbose
        pip3 install --ignore-installed 'PyYAML==5.3.1' --verbose
    else
        pip3 install 'psutil==5.5.1' 'PyYAML==5.3.1' --verbose
    fi

    # VM Only packages
    pip3 install 'textX==2.3.0' 'pydot==1.4.2' 'gitpython==3.1.14' 'pymultigen==0.2.0' 'Jinja2==2.11.3' 'influxdb-client==1.15.0' --verbose
    echo ">>>>> installed pip3 packages"
}

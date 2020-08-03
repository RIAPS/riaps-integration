#!/usr/bin/env bash
set -e

#install spdlog python logger
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

#install apparmor_monkeys
apparmor_monkeys_install(){
    PREVIOUS_PWD=$PWD
    git clone https://github.com/RIAPS/apparmor_monkeys.git /tmp/3rdparty/apparmor_monkeys
    cd /tmp/3rdparty/apparmor_monkeys
    python3 setup.py install
    cd $PREVIOUS_PWD
    sudo apt-get install apparmor-utils -y
    rm -rf /tmp/3rdparty/apparmor_monkeys
    echo ">>>>> installed apparmor_monkeys"
}

pyzmq_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/zeromq/pyzmq.git
    cd /tmp/3rdparty/pyzmq
    git checkout v17.1.2
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/pyzmq
    echo ">>>>> installed pyzmq"
}

#install bindings for czmq. Must be run after pyzmq, czmq install.
#code was pulled for external cmake build and is the correct branch prior to this call
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/czmq-$HOST_ARCH/bindings/python
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed CZMQ pybindings"
}

#install bindings for zyre. Must be run after zyre, pyzmq install.
#code was pulled for external cmake build and is the correct branch prior to this call
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty/zyre-$HOST_ARCH/bindings/python
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    echo ">>>>> installed Zyre pybindings"
}

#link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install(){
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3'
    echo ">>>>> linked pycapnp with capnproto"
}

# install prctl package
prctl_install(){
    sudo apt-get install libcap-dev -y
    pip3 install 'python-prctl==1.7'
    echo ">>>>> installed prctl"
}

#MM TODO: Python 3.8 in 20.04 can not install butter as below, Adafruit_BBIO is not available in python 3.8 (7/2020)
#         Python 3.8 has this installed already, need to overwrite: pip3 install --ignore-installed 'psutil==5.7.0'
#install other required packages
other_pip3_installs(){
    pip3 install 'pydevd==1.8.0' 'rpyc==4.1.0' 'redis==2.10.6' 'hiredis == 0.2.0' 'netifaces==0.10.7' 'paramiko==2.7.1' 'cryptography==2.9.2' 'cgroups==0.1.0' 'cgroupspy==0.1.6' 'psutil==5.4.2' 'butter==0.12.6' 'lmdb==0.94' 'fabric3==1.14.post1' 'pyroute2==0.5.2' 'minimalmodbus==0.7' 'pyserial==3.4' 'pybind11==2.2.4' 'toml==0.10.0' 'pycryptodomex==3.7.3' --verbose
    # Note when chose to update to 20.04, there is an issue installing this in Python 3.8 right now (7/2020)
    pip3 install 'Adafruit_BBIO==1.1.1'
    # Package in distro already, leaving it in site-packages
    pip3 install --ignore-installed 'PyYAML==5.1.1'
    pip3 install 'textX==1.7.1' 'graphviz==0.5.2' 'pydot==1.2.4' 'gitpython==3.1.7' 'pymultigen==0.2.0' 'Jinja2==2.10' --verbose
    echo ">>>>> installed pip3 packages"
}

#MM TODO method for installing butter for 20.04
butter_install() {
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/RIAPS/butter.git
    cd /tmp/3rdparty/butter
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/butter
    echo "installed butter"
}

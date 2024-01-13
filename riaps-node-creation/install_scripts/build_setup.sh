#!/usr/bin/env bash
set -e

cmake_func() {
    sudo apt-get update
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    echo ">>>>> installed cmake"
}

# Python3-dev and python3-setuptools are already in the base image of some architectures,
# but is needed for RIAPS setup/installation. Therefore, it is installed here to make sure it is available.
python_install() {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip python-is-python3 -y
    sudo pip3 install --upgrade pip
    echo ">>>>> installed python3"
}

curl_func() {
    sudo apt install curl -y
    echo ">>>>> installed curl"
}


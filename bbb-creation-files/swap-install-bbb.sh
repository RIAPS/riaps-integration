#!/usr/bin/env bash
set -e

# Install RT Kernel
spdlog_python_install() {
    sudo pip3 install 'pybind11==2.2.4'
    git clone https://github.com/RIAPS/spdlog-python.git /tmp/spdlog-python
    cd /tmp/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    sudo python3 setup.py install
    echo "installed spdlog_python"
}

remove_swap_file() {
    sudo swapoff -v /swapfile  # MM TODO:  did not work in a script (did by hand)
    sed -i "/swapfile/c\ " /etc/fstab
    sudo rm /swapfile
    echo "swapfile removed"
}


# Start of script actions
spdlog_python_install
remove_swap_file

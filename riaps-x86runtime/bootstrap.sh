#!/usr/bin/env bash
set -e

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, libpcap0.8, libnettle6, software-properties-common, libnss-mdns
# Python 3.6, libcurl4, libcurl3-gnutls, libncurses5, libzmq5, libgnutls30, firefox,
# libhogweed4, libgmp10, openssl (1.1.0g-2ubuntu4), snapd, net-tools
#
# Installed prior to this script: GIT, quota
#
# Need to remove: python3-crypto python3-keyrings.alt -y

# Source configurable values for the VM creation
source "vm_creation.conf"


# Source scripts and configuration needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/vm_creation.conf"
    echo ">>>>> sourced install scripts"
}

source_scripts

# Start of install script actions
check_os_version
mkdir -p /tmp/3rdparty
user_func
set_riaps_sudoer
setup_ssh_keys
rm_snap_pkg
cross_setup
java_func
cmake_func
utils_install
timesync_requirements
python_install
cython_install
curl_func
boost_install
#eclipse_func - MM removed, done manually at this time
eclipse_plugin_dep_install
add_eclipse_projects
nethogs_prereq_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_prereq_install
opendht_prereqs_install
externals_cmake_install
pycapnp_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
apparmor_monkeys_install
redis_install
butter_install
pip3_3rd_party_installs
spdlog_python_install
graphviz_install
prctl_install
rm -rf /tmp/3rdparty
add_set_tests
riaps_prereq
create_riaps_version_file

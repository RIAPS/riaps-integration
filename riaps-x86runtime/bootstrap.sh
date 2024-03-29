#!/usr/bin/env bash
set -e

# Packages already in base 20.04 image that are utilized by RIAPS Components:
# GCC 9, G++ 9, libpcap0.8, libnettle7, software-properties-common, libnss-mdns
# Python 3.8, libcurl4, libcurl3-gnutls, libncurses6, libzmq5, libgnutls30, firefox,
# libhogweed5, libgmp10, openssl (1.1.1f-1ubuntu2.5), snapd
#
# Installed prior to this script: GIT, quota
#

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
watchdog_timers
cross_setup
java_func
cmake_func
utils_install
timesync_requirements
python_install
cython_install
curl_func
boost_install
#eclipse_func - this step is done manually at this time
eclipse_plugin_dep_install
#add_eclipse_projects - these projects are now in a private repo, do this manually
nethogs_prereq_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_prereq_install
opendht_prereqs_install
capnproto_prereqs_install
gpio_install
externals_cmake_install
pycapnp_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
apparmor_monkeys_install
redis_install
spdlog_python_install
py_lmdb_install
pip3_3rd_party_installs
graphviz_install
#mininet_install - this step is done manually due to issue in mininet install script (see function for more information)
prctl_install
graphing_installs
chrome_install
#nodered_install - these two steps is done manually, the steps taken are documented in vm_utils_install.sh nodered_install()
#node_red_shortcut
rm -rf /tmp/3rdparty
add_set_tests
riaps_prereq
create_riaps_version_file

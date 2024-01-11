#!/usr/bin/env bash
set -e

# Packages already in base 20.04 & 22.04 image that are utilized by RIAPS Components:
# libpcap0.8, software-properties-common, libnss-mdns, libcurl4, libcurl3-gnutls, 
# libncurses6,  libgnutls30, libgmp10, snapd
#
# Packages already in base 20.04 image that are utilized by RIAPS Components:
# GCC 9, G++ 9, libnettle7, Python 3.8, libzmq5 (4.3.2), firefox (installed with apt),
# libhogweed5, openssl (1.1.1f-1ubuntu2.5)
#
# Packages already in base 22.04 image that are utilized by RIAPS Components:
# GCC 11, G++ 11, libnettle8, Python 3.10, libzmq5 (4.3.4), firefox (installed with snap),
# libhogweed6, openssl (3.0.2-0ubuntu1.10)
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
#snap used exclusively in 22.04 for firefox installation in the distro, so not removing
if [ $LINUX_VERSION_INSTALL = "20.04" ]; then
 rm_snap_pkg
fi
watchdog_timers
cross_setup
java_func
cmake_func
utils_install
timesync_requirements
python_install
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
capnproto_prereq_install
gpio_install
zmq_draft_apt_install
externals_cmake_install
configure_library_path
pycapnp_install
apparmor_monkeys_install
redis_install
py_lmdb_install
pip3_3rd_party_installs
graphviz_install
#mininet_install - this step is done manually due to issue in mininet install script (see function for more information)
prctl_install
# place zmq python installs at the end due to caching of newer cythons
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
graphing_installs
chrome_install
#nodered_install - these two steps is done manually, the steps taken are documented in vm_utils_install.sh nodered_install()
#node_red_shortcut
rm -rf /tmp/3rdparty
add_set_tests
#riaps_prereq - DEV: currently working with a non-apt release, no repo to add yet
create_riaps_version_file
set_UTC_timezone # in case VM created with a different timezone, helpful for .pem cert creation in secure_keys script

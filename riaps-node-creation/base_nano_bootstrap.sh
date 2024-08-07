# NOTE: THIS DEVICE IS NO LONGER SUPPORTED

#!/usr/bin/env bash
set -e

# This script configures the packages included on the Jetson Nano image
# Note:  for 1.1.20 release, the Nano image had not yet been created nor code updated

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, GIT, pkg-config, libzmq5, liblz4-1, cmake
# libpcap0.8, libnettle6, libgnutls30, libncurses5, libuuid1
#
# python3-crypto python3-keyrings.alt does exist and needs to be removed
#
# Not in base image (but will be installed):  python3-dev, python3-setuptools, pps-tools

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/node_creation_nano.conf"
    echo ">>>>> sourced install scripts"
}

quota_install() {
    sudo apt-get install quota -y
    sed -i "/root/c\/dev/root / ext4 defaults,usrquota,grpquota 0 1" /etc/fstab
    echo ">>>>> setup quotas"
}

splash_screen_update() {
    echo "################################################################################" > motd
    echo "# Acknowledgment:  The information, data or work presented herein was funded   #" >> motd
    echo "# in part by the Advanced Research Projects Agency - Energy (ARPA-E), U.S.     #" >> motd
    echo "# Department of Energy, under Award Number DE-AR0000666. The views and         #" >> motd
    echo "# opinions of the authors expressed herein do not necessarily state or reflect #" >> motd
    echo "# those of the United States Government or any agency thereof.                 #" >> motd
    echo "################################################################################" >> motd
    sudo mv motd /etc/motd
    echo ">>>>> setup splash screen"
}

# Jetson nano (4.9 kernel) /etc/network/interfaces sources the directory /etc/network/interfaces.d/
setup_network_nano() {
    sudo apt-get install net-tools -y
    echo ">>>>> copying network/interfaces-riaps to network/interfaces.d/interfaces-riaps"
    sudo mkdir -p /etc/network/interfaces.d
    cp etc/network/interfaces-riaps /etc/network/interfaces.d/interfaces-riaps
    echo ">>>>> replaced network interfaces"

    echo ">>>>> replacing resolv.conf"
    touch /etc/resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.preriaps
    cp  etc/resolv-riaps.conf /etc/resolv.conf
    echo ">>>>> replaced resolv.conf"
}


source_scripts

# Start of script actions
check_os_version
setup_peripherals
user_func
# add_spi_func - spi not setup the same way on Nano as BBB or RPi, so not setting this up at this time
rdate_install
htop_install
rm_snap_pkg
nano_install
tmux_install
timesync_requirements
freqgov_off
watchdog_timers
quota_install
splash_screen_update
setup_hostname
#setup_network_nano
python_install
curl_func
boost_install
nethogs_prereq_install
zmq_draft_apt_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_pkg_install
opendht_prereqs_install
capnproto_prereqs_install
gpio_install
cython_install
build_external_libraries
pycapnp_install
apparmor_monkeys_install
#spdlog_python_install
#butter_install - this may no longer be needed (MM - 092022)
#rpyc_install - this may no longer be needed (MM - 092022)
py_lmdb_install
pip3_3rd_party_installs
prctl_install
# move zmq python installs to last due to cython being updated to 3.0.2 for the pyzmq build
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
remove_pkgs_used_to_build
riaps_prereq
create_riaps_version_file
set_date

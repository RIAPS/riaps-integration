#!/usr/bin/env bash
set -e

# This script configures the packages included on the Raspberry Pi 4 image
#   Note: the rt kernel option is commented out and untested for latest images

# Packages already in base 18.04.4 image that are utilized by RIAPS Components:
# git, libpcap0.8, nettle6, libncurses5, curl, libuuid1, liblz4-1, libgnutls30
# vim, htop, software-properties-common
#
# Packages already in base 20.04.5 image that are utilized by RIAPS Components:
# git, libpcap0.8, nettle7, libncurses6, curl, libuuid1, liblz4-1, libgnutls30,
# libhogweed5, libgmp10, openssl (1.1.1f-1ubuntu2)
# vim, htop, software-properties-common, python3-setuptools

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/node_creation_rpi.conf"
    echo ">>>>> sourced install scripts"
}

quota_install() {
    sudo apt-get install quota -y
    sed -i "/LABEL=writable/c\LABEL=writable / ext4 defaults,usrquota,grpquota 0 0" /etc/fstab
    echo "setup quotas"
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
    echo "setup splash screen"
}


source_scripts

# Start of script actions
check_os_version
setup_peripherals
user_func
add_spi_func
rdate_install
rm_snap_pkg
tmux_install
cmake_func
timesync_requirements
random_num_gen_install
#freqgov_off - ondemand.service does not exist
watchdog_timers
quota_install
splash_screen_update
setup_hostname
setup_network
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

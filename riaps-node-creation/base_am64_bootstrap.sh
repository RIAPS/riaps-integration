#!/usr/bin/env bash
set -e

# NOTE: This script does not run automatically yet, but is currently used a guideline on
#       steps taken to create an AM64x image
 
# This script configures the packages included on the TI AM64x image

# Packages already in base Debian Bookworm image that are utilized by RIAPS Components:
# GCC 12, build-essential, libnettle8, libgnutls30,  libuuid1
#
# Note: no G++ 11, GIT, python3-smbus, 
# pps-tools, libpcap0.8, libncurses6 (has libncursesw6),

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/node_creation_am64.conf"
    echo ">>>>> sourced install scripts"
}

# MM TODO: no fstab file on this image, need to determine how this is done on the device
quota_install() {
    sudo apt-get install quota -y
    sed -i "/mmcblk0p1/c\/dev/mmcblk0p1 / ext4 noatime,errors=remount-ro,usrquota,grpquota 0 1" /etc/fstab
    echo ">>>>> setup quotas"
}

splash_screen_update() {
    build_date=$(date -Idate)
    echo "################################################################################" > motd
    echo "# Acknowledgment:  The information, data or work presented herein was funded   #" >> motd
    echo "# in part by the Advanced Research Projects Agency - Energy (ARPA-E), U.S.     #" >> motd
    echo "# Department of Energy, under Award Number DE-AR0000666. The views and         #" >> motd
    echo "# opinions of the authors expressed herein do not necessarily state or reflect #" >> motd
    echo "# those of the United States Government or any agency thereof.                 #" >> motd
    echo "################################################################################" >> motd
    sudo mv motd /etc/motd
    # Issue.net
    echo "$LINUX_DISTRO GNU/Linux $LINUX_VERSION_INSTALL" > issue.net
    echo "" >> issue.net
    echo "$LINUX_DISTRO Image $build_date">> issue.net
    echo "">> issue.net
    echo "default username:password is [riaps:riaps]">> issue.net
    sudo mv issue.net /etc/issue.net
    echo ">>>>> setup splash screen"
}


source_scripts

# Start of script actions
#check_os_version
wget_install
git_install
#setup_peripherals
user_func
#add_spi_func
rdate_install
tmux_install
htop_install
cmake_func
timesync_requirements
can_install
#random_num_gen_install
#freqgov_off
watchdog_timers
#quota_install - put in later
splash_screen_update
setup_hostname
#setup_network
iptables_install
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
setup_venv
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

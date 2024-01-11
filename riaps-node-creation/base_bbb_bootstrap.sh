#!/usr/bin/env bash
set -e

# This script configures the packages included on the Beaglebone Black image
#   Note: the rt kernel option is commented out and untested for latest images

# Packages already in base 20.04 image that are utilized by RIAPS Components:
# GCC 11, G++ 11, GIT, pkg-config, python3-dev, python3-setuptools
# pps-tools, libpcap0.8, libnettle8, libgnutls30, libncurses6, libuuid1
#
# python3-crypto python3-keyrings.alt does not exist, a desired state


# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`; do
        source "$PWD/$SCRIPTS/$i"
    done

    source "$PWD/node_creation_bbb.conf"
    echo ">>>>> sourced install scripts"
}

# Install RT Kernel
rt_kernel_install() {
    sudo apt update
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_14
    # To make sure the latest overlays are available
    sudo apt install --only-upgrade bb-cape-overlays
    echo ">>>>> installed RT Kernel"
}

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
    echo "$LINUX_DISTRO $LINUX_VERSION_INSTALL LTS" > issue.net
    echo "" >> issue.net
    echo "rcn-ee.net console $LINUX_DISTRO Image $build_date">> issue.net
    echo "">> issue.net
    echo "Support/FAQ: http://elinux.org/BeagleBoardUbuntu">> issue.net
    echo "">> issue.net
    echo "default username:password is [riaps:riaps]">> issue.net
    sudo mv issue.net /etc/issue.net
    echo ">>>>> setup splash screen"
}

#install other required packages
armhf_pyinstall(){
    pip3 install 'Adafruit_BBIO==1.2.0' --verbose
    echo ">>>>> installed armhf specific python packages"
}


source_scripts

# Start of script actions
check_os_version
wget_install
#rt_kernel_install - comment out for now, using an RT setup kernel
setup_peripherals
user_func
add_spi_func
rdate_install
vim_func
tmux_install
htop_install
rm_snap_pkg
nano_install
cmake_func
timesync_requirements
random_num_gen_install
freqgov_off
watchdog_timers
quota_install
splash_screen_update
setup_hostname
setup_network
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
build_external_libraries
pycapnp_install
apparmor_monkeys_install
#spdlog_python_install
py_lmdb_install
pip3_3rd_party_installs
armhf_pyinstall
prctl_install
# move zmq python installs to last due to cython being updated to 3.0.2 for the pyzmq build
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
remove_pkgs_used_to_build
riaps_prereq
create_riaps_version_file
set_date

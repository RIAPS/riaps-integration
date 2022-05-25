#!/usr/bin/env bash
set -e

# Packages already in base Debian Bullseye image that are utilized by RIAPS Components:
# GCC 9, GIT, liblz4-1, libpcap0.8, libgnutls30, libuuid1

# not in release: pkg-config, libzmq5, cmake, python3-dev, python3-setuptools, pps-tools
#
# different from release:  libnettle6(RIAPS)/libnettle8(Bullseye), libncurses5(RIAPS)/libcurses6(Bullseye)
# python 3.9.2 is installed (VM On 3.8.10)
#
# differences in script installs:

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

# MM TODO:  update for adding fstab information
# /dev/root  /  auto  remount,rw,usrquota,grpquota  1  1
quota_install() {
    sudo apt-get install quota -y
    sed -i "/root/c\/dev/root / ext4 defaults,usrquota,grpquota 0 1" /etc/fstab
    echo ">>>>> setup quotas"
}

# MM not included since this is under a different contract now - need to see if we want an acknowledgement here
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


source_scripts

# Start of script actions
check_os_version
setup_peripherals # dialout group already existed, added gpio/pwm/spi (3/23/21)
user_func
setup_ssh_keys
htop_install
#rm_snap_pkg - not installed on default setup
nano_install
timesync_requirements  # MM TODO: currently pps-tools is not install, find out if needed
#freqgov_off # MM TODO: held off on installing this, it is more of a nice to have (in first round)
watchdog_timers
#random_num_gen_install # MM TODO: skipped in initial sdcard setup (1/20/22), saw evidence in boot that random number generation is done (differently)
quota_install #### MM TODO: no /etc/fstab setup - # UNCONFIGURED FSTAB FOR BASE SYSTEM - manually added fstab information (see previous comment above)
#splash_screen_update # held off on this, not necessary
setup_hostname # MM TODO: did manually first so that I can tell I am booting to SD Card (instead of eMMC), there is no reason it shouldn't work
python_install
cython_install
#curl_func
boost_install
nethogs_prereq_install # MM TODO: decided to not install libncurses5-dev, but use libncurses-dev instead
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_pkg_install
#opendht_prereqs_install ##### Did not do the liblink yet, will try external build first -- did not need this to build opendht
capnproto_prereqs_install
cmake_func
build_external_libraries
pycapnp_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
apparmor_monkeys_install
butter_install
rpyc_install
py_lmdb_install
pip3_3rd_party_installs
prctl_install
remove_pkgs_used_to_build # MM TODO: remove libncurses-dev instead of libncurses5-dev for imx8
riaps_prereq # MM TODO: manually installed riaps-pycom package (do not install riaps-timesync)

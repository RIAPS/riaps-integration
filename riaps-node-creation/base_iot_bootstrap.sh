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
setup_peripherals # not needed now, not running
user_func # only did riaps user specific commands (not group steps), will need to add when putting on interfaces
setup_ssh_keys
htop_install
#rm_snap_pkg - not installed on default setup
nano_install
timesync_requirements  # held off on installing chrony for now (it removes systemd-timesyncd)  -- done 1/12/22 -- skipped in initial sdcard setup (1/20/22)
freqgov_off # held off on installing this, it is more of a nice to have (in first round)
watchdog_timers # held off on setting this up, it is more of a nice to have (in first round)  -- done 1/12/22 -- skipped in initial sdcard setup (1/20/22)
random_num_gen_install # skipped in initial sdcard setup (1/20/22), saw evidence in boot that random number generation is done (differently)
quota_install #### no /etc/fstab setup - # UNCONFIGURED FSTAB FOR BASE SYSTEM - -- skipped in initial sdcard setup (1/20/22)
splash_screen_update # held off on this, not necessary
setup_hostname # held off on this, not necessary - did manually first so that I can tell I am booting to SD Card (instead of eMMC)
setup_network_nano # held off on this, network is not setup - net-tools already installed
python_install ### hold off on this until after external builds, it will be step 2 - done 1/12/22 -- done (1/20/22)
cython_install ### wait until above is added (need pip) - done 1/12/22 -- done (1/20/22)
#curl_func
boost_install
nethogs_prereq_install # decided to not install libncurses5-dev, but use libncurses-dev instead (see if there is a build issue with this decision - 1/20/22)
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_pkg_install
#opendht_prereqs_install ##### Did not do the liblink yet, will try external build first -- did not need this build opendht
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
remove_pkgs_used_to_build # held off on this until system used for a little bit
riaps_prereq
#create_riaps_version_file

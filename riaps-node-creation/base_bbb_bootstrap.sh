#!/usr/bin/env bash
set -e

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, GIT, pkg-config, python3-dev, python3-setuptools
# pps-tools, libpcap0.8, nettle6, libgnutls30, libncurses5

# Script Variables
RIAPSAPPDEVELOPER=riaps
ARCHTYPE=armhf
ARCHINSTALL=arm-linux-gnueabihf

# Script functions
check_os_version() {
    # Need to write code here to check OS version and architecture.
    # The installation should fail if the OS version is not correct.
    true

}

# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

#MM TODO: try a for loop on directory
# for i in `ls $PWD/$SCRIPTS`;do source "$PWD/$SCRIPTS/$i" ;done

    source "$PWD/$SCRIPTS/user_functions.sh"
    source "$PWD/$SCRIPTS/utils_install.sh"
    source "$PWD/$SCRIPTS/build_setup.sh"
    source "$PWD/$SCRIPTS/hw_setup.sh"
    source "$PWD/$SCRIPTS/network_setup.sh"
    source "$PWD/$SCRIPTS/apt_pkg_installs.sh"
    source "$PWD/$SCRIPTS/python_installs.sh"
    echo "sourced install scripts"
}

# Install RT Kernel
rt_kernel_install() {
    sudo apt update
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_14
    # To make sure the latest overlays are available
    sudo apt install --only-upgrade bb-cape-overlays
    echo "installed RT Kernel"
}

quota_install() {
    sudo apt-get install quota -y
    sed -i "/mmcblk0p1/c\/dev/mmcblk0p1 / ext4 noatime,errors=remount-ro,usrquota,grpquota 0 1" /etc/fstab
    echo "setup quotas"
}

#MM TODO: update version/date
splash_screen_update() {
    echo "################################################################################" > motd
    echo "# Acknowledgment:  The information, data or work presented herein was funded   #" >> motd
    echo "# in part by the Advanced Research Projects Agency - Energy (ARPA-E), U.S.     #" >> motd
    echo "# Department of Energy, under Award Number DE-AR0000666. The views and         #" >> motd
    echo "# opinions of the authors expressed herein do not necessarily state or reflect #" >> motd
    echo "# those of the United States Government or any agency thereof.                 #" >> motd
    echo "################################################################################" >> motd
    sudo mv motd /etc/motd
    # Issue.net
    echo "Ubuntu 18.04.1 LTS" > issue.net
    echo "" >> issue.net
    echo "rcn-ee.net console Ubuntu Image 2018-09-11">> issue.net
    echo "">> issue.net
    echo "Support/FAQ: http://elinux.org/BeagleBoardUbuntu">> issue.net
    echo "">> issue.net
    echo "default username:password is [riaps:riaps]">> issue.net
    sudo mv issue.net /etc/issue.net
    echo "setup splash screen"
}

# Create a swap file to allow spdlog-python to compile using swap
add_swapfile() {
    sudo fallocate -l 1G /swapfile
    sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    echo "setup a swapfile"
}

#install other required packages
armhf_pyinstall(){
    pip3 install 'Adafruit_BBIO == 1.1.1'
    echo "installed armhf specific python packages"
}


# Start of script actions
check_os_version
source_scripts
rt_kernel_install
setup_peripherals
user_func
rdate_install
vim_func
htop_install
cmake_func
timesync_requirements
freqgov_off
python_install
cython_install
curl_func
boost_install
nethogs_prereq_install
zyre_czmq_prereq_install
watchdog_timers
quota_install $RIAPSAPPDEVELOPER
splash_screen_update
setup_hostname
setup_network
security_pkg_install
setup_ssh_keys $RIAPSAPPDEVELOPER
# Swapfile needs to be done before running this script or
# installs like spdlog will not run
#add_swapfile
spdlog_install
apparmor_monkeys_install
gnutls_install
msgpack_install
opendht_prereqs_install $ARCHINSTALL
externals_cmake_install $ARCHTYPE
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
pycapnp_install
other_pip3_installs
armhf_pyinstall
prctl_install
remove_pkgs_used_to_build
setup_riaps_repo $ARCHTYPE

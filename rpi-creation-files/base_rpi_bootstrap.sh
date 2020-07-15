#!/usr/bin/env bash
set -e


# MM TODO: update this list
# Packages already in base 20.04.4 image that are utilized by RIAPS Components:
# git, libpcap0.8, nettle7, libncurses6, curl, libuuid1, liblz4-1, libgnutls30,
# libhogweed5, libgmp10, openssl (1.1.1f-1ubuntu2)
# vim, htop, software-properties-common, python3-setuptools

# MM TODO: Packages to add?
# cmake installs GCC-9, previously used GCC 7, G++ 7
# Not sure where this is needed: python3-dev
# Might be needed for riaps-timesync, but did not yet install or test that: pps-tools (why needed?)


# Script Variables
RIAPSAPPDEVELOPER=riaps

# Script functions
check_os_version() {
    # Need to write code here to check OS version and architecture.
    # The installation should fail if the OS version is not correct.
    true

}

# MM TODO: update
# Install RT Kernel
# https://lemariva.com/blog/2019/09/raspberry-pi-4b-preempt-rt-kernel-419y-performance-test
rt_kernel_install() {
    sudo apt update
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_14
    # To make sure the latest overlays are available
    sudo apt install --only-upgrade bb-cape-overlays
    echo "installed RT Kernel"
}

user_func() {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        getent group gpio || sudo groupadd gpio
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER
        sudo usermod -aG dialout $RIAPSAPPDEVELOPER
        sudo usermod -aG gpio  $RIAPSAPPDEVELOPER
        sudo usermod -aG pwm $RIAPSAPPDEVELOPER
        sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
        cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
        echo "created user accounts"
    fi
}

# Needed to allow apt-get update to work properly
rdate_install() {
    sudo apt-get install rdate -y
    sudo rdate -n -4 time.nist.gov
    echo "installed rdate"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo "snap package manager removed"
}

utils_install() {
    sudo apt-get install net-tools -y
    echo "installed utils"
}

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    echo "installed cmake"
}

timesync_requirements() {
    sudo apt-get install linuxptp libnss-mdns gpsd chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo "installed timesync requirements"
}

freqgov_off() {
    sudo apt-get install cpufrequtils -y
    touch /etc/default/cpufrequtils
    echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
    sudo systemctl disable ondemand
    sudo /etc/init.d/cpufrequtils restart
    echo "setup frequency and governor"
}

python_install() {
    sudo apt-get install python3-pip -y
    sudo pip3 install --upgrade pip
    sudo pip3 install pydevd
    echo "installed python3 and pydev"
}

cython_install() {
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.28.5' --verbose
    echo "installed cython"
}

boost_install() {
    sudo apt-get install libboost-all-dev -y
    echo "installed boost"
}

# install nethogs pre-requisites
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libncurses5-dev -y
    echo "installed nethogs prerequisites"
}

butter_install() {
    PREVIOUS_PWD=$PWD
    cd /tmp/3rdparty
    git clone https://github.com/RIAPS/butter.git
    cd /tmp/3rdparty/butter
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/butter
    echo "installed butter"
}

zyre_czmq_prereq_install() {
    sudo apt-get install libzmq5 libzmq3-dev -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install pkg-config -y
    echo "installed CZMQ and Zyre prerequisites"
}

watchdog_timers() {
    echo " " >> /etc/sysctl.conf
    echo "###################################################################" >> /etc/sysctl.conf
    echo "# Enable Watchdog Timer on Kernel Panic and Kernel Oops" >> /etc/sysctl.conf
    echo "# Added for RIAPS Platform (01/25/18, MM)" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
    echo "kernel.panic = 5" >> /etc/sysctl.conf
    echo "added watchdog timer values"
}

quota_install() {
    sudo apt-get install quota -y
    sed -i "/LABEL=writable/c\LABEL=writable / ext4 defaults,usrquota,grpquota 0 0" /etc/fstab
# MM TODO: add cgroups enabling in /boot/firmware/cmdline.txt - not tested yet
# what to add: “cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1”
# after image is ready, test by: grep mem /proc/cgroups
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
# MM TODO: update when realtime build is complete - for now comment out
    # Issue.net
#    echo "Ubuntu 18.04.4 LTS" > issue.net
#    echo "" >> issue.net
#    echo "rcn-ee.net console Ubuntu Image 2018-09-11">> issue.net
#    echo "">> issue.net
#    echo "Support/FAQ: http://elinux.org/BeagleBoardUbuntu">> issue.net
#    echo "">> issue.net
#    sudo mv issue.net /etc/issue.net
    echo "setup splash screen"
}

setup_hostname() {
    cp usr/bin/set_unique_hostname /usr/bin/set_unique_hostname
    echo "setup hostname"
}

setup_peripherals() {
    getent group gpio ||groupadd gpio
    getent group dialout ||groupadd dialout
    getent group pwm ||groupadd pwm

    echo "setup peripherals - gpio, uart, and pwm"
}

setup_network() {
    sudo apt-get install net-tools -y
    echo "replacing network/interfaces with network/interfaces-riaps"
    echo "copying old network/interfaces to network/interfaces.preriaps"
    touch /etc/network/interfaces
    cp /etc/network/interfaces /etc/network/interfaces.preriaps
    cp etc/network/interfaces-riaps /etc/network/interfaces
    echo "replaced network interfaces"

    echo "replacing resolv.conf"
    touch /etc/resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.preriaps
    cp  etc/resolv-riaps.conf /etc/resolv.conf
    echo "replaced resolv.conf"
}

# Install security packages that take a long time compiling on the RPi to minimize user RIAPS installation time
security_pkg_install() {
    echo "add security packages"
    sudo pip3 install 'paramiko==2.7.1' 'cryptography==2.9.2' --verbose
    sudo apt-get install apparmor-utils -y
# does not exist in RPi default setup
#    sudo apt-get remove python3-crypto python3-keyrings.alt -y
    echo "security packages setup"
}

# This function requires that bbb_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/bbb_initial_keys/id_rsa.pub
# be placed on the bbb as this script is run
setup_ssh_keys() {
    sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/.ssh
    sudo -H -u $RIAPSAPPDEVELOPER cat bbb_initial_keys/bbb_initial.pub >> /home/$RIAPSAPPDEVELOPER/.ssh/authorized_keys
    chmod 600 /home/$RIAPSAPPDEVELOPER/.ssh/authorized_keys
    chown -R $RIAPSAPPDEVELOPER:$RIAPSAPPDEVELOPER /home/$RIAPSAPPDEVELOPER/.ssh
    echo "Added unsecured public key to authorized keys for $RIAPSAPPDEVELOPER"
}

spdlog_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/spdlog-python.git $TMP/spdlog-python
    cd $TMP/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed spdlog"
}

apparmor_monkeys_install() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/RIAPS/apparmor_monkeys.git $TMP/apparmor_monkeys
    cd $TMP/apparmor_monkeys
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed apparmor_monkeys"
}

# install gnutls
gnutls_install(){
    sudo apt-get install libgnutls28-dev -y
    echo "installed gnutls"
}

#install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2 libmsgpack-dev -y
    echo "installed msgpack"
}

#install opendht prerequisites - expect libncurses5-dev installed
opendht_prereqs_install() {
    sudo apt-get install nettle-dev -y
    # run liblinks script to link gnutls and msgppack
    chmod +x /home/ubuntu/riaps-integration/rpi-creation-files/liblinks.sh
    PREVIOUS_PWD=$PWD
    cd /usr/lib/aarch64-linux-gnu
    sudo /home/ubuntu/riaps-integration/rpi-creation-files/liblinks.sh
    cd $PREVIOUS_PWD
    echo "installed opendht prerequisites"
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD
    mkdir -p /tmp/3rdparty/build
    cp CMakeLists.txt /tmp/3rdparty/.
    cd /tmp/3rdparty/build
    cmake ..
    make
    cd $PREVIOUS_PWD
    sudo rm -rf /tmp/3rdparty/
    echo "cmake install complete"
}

pyzmq_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/pyzmq.git $TMP/pyzmq
    cd $TMP/pyzmq
    git checkout v17.1.2
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed pyzmq"
}

#install bindings for czmq. Must be run after pyzmq, czmq install.
czmq_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq_pybindings
    cd $TMP/czmq_pybindings/bindings/python
    git checkout 9ee60b18e8bd8ed4adca7fdaff3e700741da706e
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed CZMQ pybindings"
}

#install bindings for zyre. Must be run after zyre, pyzmq install.
zyre_pybindings_install(){
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre_pybindings
    cd $TMP/zyre_pybindings/bindings/python
    git checkout b36470e70771a329583f9cf73598898b8ee05d14
    sudo pip3 install . --verbose
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo "installed Zyre pybindings"
}

#link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3'
    echo "linked pycapnp with capnproto"
}

#install other required packages
other_pip3_installs(){
    pip3 install 'pydevd==1.8.0' 'rpyc==4.1.0' 'redis==2.10.6' 'hiredis == 0.2.0' 'netifaces==0.10.7' 'cgroups==0.1.0' 'cgroupspy==0.1.6' 'lmdb==0.94' 'fabric3==1.14.post1' 'pyroute2==0.5.2' 'minimalmodbus==0.7' 'pyserial==3.4' 'pybind11==2.2.4' 'toml==0.10.0' 'pycryptodomex==3.7.3' --verbose
    # no version for RPi - pip3 install 'Adafruit_BBIO==1.1.1'
    # Package in distro already, leaving it in site-packages
    pip3 install --ignore-installed 'PyYAML==5.1.1'
    pip3 install --ignore-installed 'psutil==5.7.0'
    echo "installed pip3 packages"
}

# install prctl package
prctl_install() {
    sudo apt-get install libcap-dev -y
    # not able to do pip3 install 'python-prctl==1.7' on RPi
    PREVIOUS_PWD=$PWD
    git clone http://github.com/seveas/python-prctl
    cd python-prctl/
    python3 setup.py build
    sudo python3 setup.py install
    cd $PREVIOUS_PWD
    echo "installed prctl"
}

# To regain disk space on the BBB, remove packages that were installed as part of the build process (i.e. -dev)
remove_pkgs_used_to_build(){
    sudo apt-get remove libboost-all-dev libffi-dev libgnutls28-dev libncurses5-dev -y
    sudo apt-get remove libpcap-dev libreadline-dev libsystemd-dev -y
    sudo apt-get remove libzmq3-dev libmsgpack-dev nettle-dev -y
    echo "removed packages used in building process, no longer needed"
}

setup_riaps_repo() {
    sudo apt-get install apt-transport-https -y

    # Add RIAPS repository
    echo "get riaps public key"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    echo "add repo to sources"
    sudo add-apt-repository -r "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main" || true
    sudo add-apt-repository -n "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main"
    sudo apt-get update
    echo "riaps aptrepo setup"
}

# Start of script actions
check_os_version
rt_kernel_install
setup_peripherals
user_func
rdate_install
rm_snap_pkg
utils_install
cmake_func
timesync_requirements
freqgov_off
python_install
cython_install
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
butter_install
other_pip3_installs
spdlog_install
apparmor_monkeys_install
gnutls_install
msgpack_install
opendht_prereqs_install
externals_cmake_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
pycapnp_install
prctl_install
remove_pkgs_used_to_build
setup_riaps_repo

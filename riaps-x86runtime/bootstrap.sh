#!/usr/bin/env bash

# Packages already in base 20.04 image that are utilized by RIAPS Components:
# GCC 10, GCC 9, libpcap0.8, software-properties-common (0.98.9), vim, libnss-mdns (0.14.1),
# Python 3.8, libcurl4, libcurl3-gnutls, libncurses6, libzmq5, pkg-config, libgnutls30, firefox,
# libnettle7, libhogweed5, libgmp10, openssl 1.1.1f-1ubuntu2
#
# Installed prior to this script: GIT, quota
# Need to make sure python3-crypto and python3-keyrings.alt are not installed due to pycryptodomex install (not in 20.04 image)


# Script Variables
RIAPSAPPDEVELOPER=riaps

# Script functions

# User can supply ssh key pair, but must supply an intended name pair
parse_args()
{
    for ARGUMENT in "$@"
    do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)
        case "$KEY" in
            public_key)               PUBLIC_KEY=${VALUE} ;;
            private_key)              PRIVATE_KEY=${VALUE} ;;
            help)                     HELP="true" ;;
            *)
        esac
    done
    pwd
    if [ -e "$PUBLIC_KEY" ] && [ -e "$PRIVATE_KEY" ]
    then
        echo "Found user ssh keys.  Will use them"
    else
        echo "Did not find public_key=<name>.pub private_key=<name>.key. Generating it now."
        mkdir -p /home/riapsadmin/.ssh
        ssh-keygen -N "" -q -f $PRIVATE_KEY
    fi
}

print_help()
{
    if [ "$HELP" = "true" ]; then
        echo "usage: test_key_move [help] [=]"
        echo "arguments:"
        echo "help                       show this help message and exit"
        echo "public_key=<name>.pub      name of public key file"
        echo "private_key=<name>.key     name of private file"
        exit
    fi
}

# Setup User Account
user_func () {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        sudo chage -d 0 $RIAPSAPPDEVELOPER
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER
        sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
        echo "created user accounts"
    fi
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
}

# Configure for cross functional compilation - this is vagrant box config dependent
cross_setup() {
    sudo apt-get install apt-transport-https -y

    echo "add amd64, i386"
    # Qualify the architectures for existing repositories
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal-updates universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal  multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal-updates multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal-updates multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu focal-security main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu focal-security main restricted"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu focal-security universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu focal-security universe"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu focal-security multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu focal-security multiverse"

    echo "add armhf, arm64"
    # Add armhf repositories
    sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports focal main universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports focal main universe multiverse"

    sudo add-apt-repository -r "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main universe multiverse" || true
    sudo add-apt-repository  -n "deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports focal-updates main universe multiverse"

    echo "updated sources.list for multiarch"

    sudo dpkg --add-architecture armhf
    sudo dpkg --add-architecture arm64
    sudo apt-get update
    echo "packages update complete for multiarch"
    sudo apt-get install crossbuild-essential-armhf crossbuild-essential-arm64 gdb-multiarch -y
    sudo apt-get install build-essential -y
    echo "setup multi-arch capabilities complete"
}

java_func () {
    sudo apt-get install openjdk-8-jre-headless -y
    echo "installed java"
}

# RIAPS was developed using GCC/G++ 7 compilers, yet Ubuntu 20.04 is configured for GCC/G++ 9
# Setup update-alternative to have this VM use GCC/G++ 7.
#MM TODO: this part is still in development.  Most likely it will stay with gcc-9 if all builds well and this section will not be needed
config_gcc() {
    sudo apt -y install gcc-7 g++-7

    sudo apt -y install gcc-7:armhf g++-7:armhf
    sudo apt -y install gcc-7:arm64 g++-7:arm64
    # Setup GCC-7 as default in all architectures
    # amd64
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
    sudo update-alternatives --set gcc /usr/bin/gcc-7
    sudo update-alternatives --set g++ /usr/bin/g++-7
    # armhf
    sudo update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc gcc /usr/bin/arm-linux-gnueabihf-gcc-7 7
    sudo update-alternatives --install /usr/bin/arm-linux-gnueabihf-gcc gcc /usr/bin/arm-linux-gnueabihf-gcc-9 9
    sudo update-alternatives --install /usr/bin/arm-linux-gnueabihf-g++ g++ /usr/bin/arm-linux-gnueabihf-g++-7 7
    sudo update-alternatives --install /usr/bin/arm-linux-gnueabihf-g++ g++ /usr/bin/arm-linux-gnueabihf-g++-9 9
    sudo update-alternatives --set gcc /usr/bin/arm-linux-gnueabihf-gcc-7
    sudo update-alternatives --set g++ /usr/bin/arm-linux-gnueabihf-g++-7
    # arm64
    sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc gcc /usr/bin/aarch64-linux-gnu-gcc-7 7
    sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc gcc /usr/bin/aarch64-linux-gnu-gcc-9 9
    sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ g++ /usr/bin/aarch64-linux-gnu-g++-7 7
    sudo update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ g++ /usr/bin/aarch64-linux-gnu-g++-9 9
    sudo update-alternatives --set gcc /usr/bin/aarch64-linux-gnu-gcc-7
    sudo update-alternatives --set g++ /usr/bin/aarch64-linux-gnu-g++-7

    # Print version to show it worked as desired
    gcc --version
    g++ --version
    arm-linux-gnueabihf-gcc --version
    arm-linux-gnueabihf-g++ --version
    aarch64-linux-gnu-gcc --version
    aarch64-linux-gnu-g++ --version
    echo "configured gcc/g++"
}

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    sudo apt-get install libreadline-dev:armhf libreadline-dev:arm64 -y
    echo "installed cmake"
}

utils_install() {
    sudo apt-get install htop -y
    sudo apt-get install openssl openssh-server -y
    sudo apt-get install net-tools -y
    # make sure date is correct
    sudo apt-get install rdate -y
    # rdate command can timeout, restart script from here if this happens
    sudo rdate -n -4 time.nist.gov
    echo "installed utils"
}

# Required for riaps-timesync
# Assumes libnss-mdns is already installed
timesync_requirements() {
    sudo apt-get install linuxptp gpsd chrony -y
    sudo apt-get install libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo "installed timesync requirements"
}

python_install () {
    sudo apt-get install python3-dev python3-setuptools -y
    sudo apt-get install python3-pip -y
    sudo apt-get install libpython3-dev:armhf libpython3-dev:arm64 -y
    sudo pip3 install --upgrade pip
    echo "installed python3"
}

# Assumes that Cython3 is not on the base release (20.04 does not have it)
cython_install() {
    sudo pip3 install 'git+https://github.com/cython/cython.git@0.28.5'
    echo "installed cython"
}

curl_func () {
    sudo apt install curl -y
    echo "installed curl"
}

boost_install() {
    sudo apt-get install libboost-dev -y
    sudo apt-get install libboost-dev:armhf libboost-dev:arm64 -y
    echo "installed boost"
}

#eclipse install
eclipse_shortcut() {
    shortcut=/home/$1/Desktop/Eclipse.desktop
    sudo -H -u $1 mkdir -p /home/$1/Desktop
    sudo -H -u $1 cat <<EOT >$shortcut
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Eclipse
Name[en_US]=Eclipse
Icon=/home/$1/eclipse/icon.xpm
Exec=/home/$1/eclipse/eclipse -data /home/$1/workspace
EOT

    sudo chmod +x /home/$1/Desktop/Eclipse.desktop
}

eclipse_func() {
    if [ ! -d "/home/$1/eclipse" ]
    then
       wget http://www.eclipse.org/downloads/download.php?file=/oomph/epp/oxygen/R2/eclipse-inst-linux64.tar.gz
       tar -xzvf eclipse-inst-linux64.tar.gz
       sudo mv eclipse /home/$1/.
       sudo chown -R $1:$1 /home/$1/eclipse
       sudo -H -u $1 chmod +x /home/$1/eclipse/eclipse
       eclipse_shortcut $1
    else
       echo "eclipse already installed at /home/$1/eclipse"
    fi
}

# Dependencies for RIAPS eclipse plugin
eclipse_plugin_dep_install() {
    sudo apt-get install clang-format -y
}

# install nethogs pre-requisites
# Assumes libncurses6  is already installed
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libpcap-dev:armhf libpcap-dev:arm64 -y
    sudo apt-get install libncurses5-dev -y
    echo "installed nethogs prerequisites"
}

butter_install() {
    cd /tmp/3rdparty
    git clone https://github.com/RIAPS/butter.git
    cd /tmp/3rdparty/butter
    sudo python3 setup.py install
    rm -rf /tmp/3rdparty/butter
    echo "installed butter"
}

#install other required packages
other_pip3_installs(){
    pip3 install 'pydevd==1.8.0' 'rpyc==4.1.0' 'redis==2.10.6' 'hiredis == 0.2.0' 'netifaces==0.10.7' 'paramiko==2.7.1' 'cryptography==2.9.2' 'cgroups==0.1.0' 'cgroupspy==0.1.6' 'lmdb==0.94' 'fabric3==1.14.post1' 'pyroute2==0.5.2' 'minimalmodbus==0.7' 'pyserial==3.4' 'pybind11==2.2.4' 'toml==0.10.0' 'pycryptodomex==3.7.3' --verbose
    # There is an issue installing this in Python 3.8 right now (7/2020)
    #pip3 install 'Adafruit_BBIO==1.1.1'
    # Package in distro already, leaving it in site-packages
    pip3 install --ignore-installed 'PyYAML==5.1.1'
    pip3 install --ignore-installed 'psutil==5.7.0'
    pip3 install 'textX==1.7.1' 'graphviz==0.5.2' 'pydot==1.2.4' 'gitpython==2.1.11' 'pymultigen==0.2.0' 'Jinja2==2.10' --verbose
    echo "installed pip3 packages"
}

#install apparmor_monkeys
apparmor_monkeys_install(){
    git clone https://github.com/RIAPS/apparmor_monkeys.git /tmp/3rdparty/apparmor_monkeys
    cd /tmp/3rdparty/apparmor_monkeys
    python3 setup.py install
    sudo apt-get install apparmor-utils -y
    rm -rf /tmp/3rdparty/apparmor_monkeys
    echo "installed apparmor_monkeys"
}

#install spdlog python logger
spdlog_python_install(){
    git clone https://github.com/RIAPS/spdlog-python.git /tmp/3rdparty/spdlog-python
    cd /tmp/3rdparty/spdlog-python
    git clone -b v0.17.0 --depth 1 https://github.com/gabime/spdlog.git
    python3 setup.py install
    rm -rf /tmp/3rdparty/spdlog-python
	echo "installed spdlog python"
}

#install libraries for czmq and zyre
# Assumes libzmq5 and pkg-config are already installed
zyre_czmq_prereq_install() {
    sudo apt-get install libzmq3-dev -y
    sudo apt-get install libzmq3-dev:armhf libzmq3-dev:arm64 -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libsystemd-dev:armhf libsystemd-dev:arm64 -y
    sudo apt-get install libuuid1:armhf liblz4-1:armhf -y
    sudo apt-get install libuuid1:arm64 liblz4-1:arm64 -y
    echo "installed CZMQ and Zyre prerequisites"
}

pyzmq_install(){
    cd /tmp/3rdparty
    git clone https://github.com/zeromq/pyzmq.git
    cd /tmp/3rdparty/pyzmq
    git checkout v17.1.2
    sudo python3 setup.py install
    echo "installed pyzmq"
    rm -rf /tmp/3rdparty/pyzmq
}

#install bindings for czmq. Must be run after pyzmq, czmq install.
czmq_pybindings_install(){
    cd /tmp/3rdparty/czmq-amd64/bindings/python
    sudo pip3 install . --verbose
    echo "installed CZMQ pybindings"
}

#install bindings for zyre. Must be run after zyre, pyzmq install.
zyre_pybindings_install(){
    cd /tmp/3rdparty/zyre-amd64/bindings/python
    sudo pip3 install . --verbose
    echo "installed Zyre pybindings"
}

#link pycapnp with installed library. Must be run after capnproto install.
pycapnp_install() {
    CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib pip3 install 'pycapnp==0.6.3'
    echo "linked pycapnp with capnproto"
}

# install gnutls
# Assumes libgnutls30 is already installed
gnutls_install(){
    sudo apt-get install libgnutls30:armhf libgnutls30:arm64 -y
    sudo apt-get install libgnutls28-dev -y
    echo "installed gnutls"
}

#install msgpack
msgpack_install(){
    sudo apt-get install libmsgpackc2:amd64 -y
    sudo apt-get install libmsgpackc2:armhf libmsgpackc2:arm64 -y
    sudo apt-get install libmsgpack-dev:amd64 -y
    echo "installed msgpack"
}

#install opendht prerequisites
# Assumes libncurses5-dev is install (done for nethogs above)
opendht_prereqs_install() {
    sudo apt-get install libncurses5-dev:armhf libncurses5-dev:arm64 -y
    sudo apt-get install nettle-dev -y
    sudo apt-get install nettle-dev:armhf nettle-dev:arm64 -y
    # run liblinks script to link gnutls and msgppack
    chmod +x /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    cd /usr/lib/arm-linux-gnueabihf
    sudo /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    cd /usr/lib/aarch64-linux-gnu
    sudo /home/riapsadmin/riaps-integration/riaps-x86runtime/liblinks.sh
    echo "installed opendht prerequisites"
}

# install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    cmake -Darch=amd64 ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-amd64
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    cmake -Darch=armhf ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-armhf
    mkdir -p /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    cmake -Darch=arm64 ..
    make
    cd /home/riapsadmin/riaps-integration/riaps-x86runtime
    rm -rf /home/riapsadmin/riaps-integration/riaps-x86runtime/build-arm64
    echo "cmake install complete"
}

# install redis
redis_install () {
   if [ ! -f "/usr/local/bin/redis-server" ]; then
    wget http://download.redis.io/releases/redis-4.0.11.tar.gz
    tar xzf redis-4.0.11.tar.gz
    make -C redis-4.0.11
    sudo make -C redis-4.0.11 install
    rm -rf redis-4.0.11
    rm -rf redis-4.0.11.tar.gz
    echo "installed redis"
   else
     echo "redis already installed. skipping"
   fi
}

graphviz_install() {
    sudo apt-get install graphviz xdot -y
    echo "installed graphviz"
}

# install prctl package
prctl_install() {
    sudo apt-get install libcap-dev -y
    pip3 install 'python-prctl==1.7'
}

riaps_prereq() {
    # Add RIAPS repository
    sudo add-apt-repository -r "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main" || true
    sudo add-apt-repository -n "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ focal main"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
    sudo cp /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps_install_amd64.sh /home/$1/.
    sudo chown $1:$1 /home/$1/riaps_install_amd64.sh
    sudo -H -u $1 chmod 711 /home/$1/riaps_install_amd64.sh
    #./riaps_install_amd64.sh
}

setup_ssh_keys () {
    # Setup user (or generated) ssh keys for VM
    sudo -H -u $1 mkdir -p /home/$1/.ssh
    sudo cp $PUBLIC_KEY /home/$1/.ssh/id_rsa.pub
    sudo cp $PRIVATE_KEY /home/$1/.ssh/id_rsa.key
    sudo chown $1:$1 /home/$1/.ssh/id_rsa.pub
    sudo chown $1:$1 /home/$1/.ssh/id_rsa.key
    sudo -H -u $1 cat /home/$1/.ssh/id_rsa.pub >> /home/$1/.ssh/authorized_keys
    sudo chown $1:$1 /home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 400 /home/$1/.ssh/id_rsa.key
    #sudo -H -u $1
    echo "# RIAPS:  Add SSH keys to ssh agent on login" >> /home/$1/.bashrc
    #sudo -H -u $1
    echo "ssh-add /home/$1/.ssh/id_rsa.key" >> /home/$1/.bashrc

    # Setup BBB ssh keys for use with VM
    sudo cp -r bbb_initial_keys /home/$1/.
    sudo chown $1:$1 -R /home/$1/bbb_initial_keys
    sudo -H -u $1 chmod 400 /home/$1/bbb_initial_keys/bbb_initial.key
    #sudo -H -u $1
    echo "ssh-add /home/$1/bbb_initial_keys/bbb_initial.key" >> /home/$1/.bashrc

    # Transfer BBB rekeying script
    sudo cp secure_keys /home/$1/.
    sudo chown $1:$1 /home/$1/secure_keys
    sudo -H -u $1 chmod 700 /home/$1/secure_keys
    echo "Added user key to authorized keys for $1. Use bbb_initial keys for initial communication with the beaglebones"
}

add_set_tests () {
    sudo -H -u $1 mkdir -p /home/$1/env_setup_tests/WeatherMonitor
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/env_setup_tests/WeatherMonitor /home/$1/env_setup_tests/
    sudo chown $1:$1 -R /home/$1/env_setup_tests/WeatherMonitor
    echo "Added development environment tests"
}

# Start of script actions
set -e
mkdir -p /tmp/3rdparty
parse_args $@
print_help
user_func
setup_ssh_keys $RIAPSAPPDEVELOPER
rm_snap_pkg
cross_setup
java_func
config_gcc
cmake_func
utils_install
timesync_requirements
python_install
cython_install
curl_func
boost_install
#eclipse_func $RIAPSAPPDEVELOPER - MM removed, done manually at this time
eclipse_plugin_dep_install
nethogs_prereq_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
opendht_prereqs_install
externals_cmake_install
pycapnp_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
apparmor_monkeys_install
redis_install
butter_install
other_pip3_installs
spdlog_python_install
graphviz_install
prctl_install
rm -rf /tmp/3rdparty
add_set_tests $RIAPSAPPDEVELOPER
riaps_prereq $RIAPSAPPDEVELOPER

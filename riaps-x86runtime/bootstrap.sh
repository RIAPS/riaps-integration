#!/usr/bin/env bash

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, GIT, pkg-config, python3-dev, python3-setuptools
# pps-tools, libpcap0.8, nettle6

# Script Variables
RIAPSAPPDEVELOPER=riaps

# Script functions

# User must supply ssh key pair
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
        ssh-keygen -N "" -q -f $PRIVATE_KEY
        mv $PRIVATE_KEY.pub $PUBLIC_KEY
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

# Configure for cross functional compilation - this is vagrant box config dependent
cross_setup() {
    sudo apt-get install software-properties-common apt-transport-https -y

    echo "add amd64, i386"
    # Qualify the architectures for existing repositories
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic universe"
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic multiverse"
    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse"
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse"

    sudo add-apt-repository -r "deb http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security main restricted" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security main restricted"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security universe" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security universe"

    sudo add-apt-repository -r "deb http://security.ubuntu.com/ubuntu bionic-security multiverse" || true
    sudo add-apt-repository -n "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security multiverse"

    echo "add armhf"
    # Add armhf repositories
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse" || true
    sudo add-apt-repository -n "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports bionic main universe multiverse"

    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse" || true
    sudo add-apt-repository  -n "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports bionic-updates main universe multiverse"

    echo "updated sources.list for multiarch"

    sudo dpkg --add-architecture armhf
    sudo apt-get update
    echo "packages update complete for multiarch"
    sudo apt-get install crossbuild-essential-armhf gdb-multiarch -y
    sudo apt-get install build-essential -y
    echo "setup multi-arch capabilities complete"
}


vim_func() {
    sudo apt-get install vim -y
    echo "installed vim"
}

java_func () {
    sudo apt-get install openjdk-8-jre-headless -y
    echo "installed java"
}

cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install byacc flex libtool libtool-bin -y
    sudo apt-get install autoconf autogen -y
    sudo apt-get install libreadline-dev -y
    sudo apt-get install libreadline-dev:armhf -y
    echo "installed cmake"
}

utils_install() {
    sudo apt-get install htop -y
    sudo apt-get install openssh-server -y
}

# Required for riaps-timesync
timesync_requirements() {
    sudo apt-get install linuxptp libnss-mdns gpsd chrony -y
    sudo apt-get install libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo "installed timesync requirements"
}

python_install () {
    sudo apt-get install python3-pip -y
    sudo apt-get install libpython3-dev:armhf -y
    sudo pip3 install --upgrade pip
    sudo pip3 install pydevd
    echo "installed python3 and pydev"
}

curl_func () {
    sudo apt install curl -y
    echo "installed curl"
}

boost_install() {
    sudo apt-get install libboost-dev -y
    sudo apt-get install libboost-dev:armhf -y
    echo "installed boost"
}

# Not currently installed since nethogs is built in riaps-externals,
# this installed on the build machine (MM)
nethogs_prereq_install() {
    sudo apt-get install libpcap-dev -y
    sudo apt-get install libpcap-dev:armhf -y
    echo "installed nethogs prerequisites"
}

zyre_czmq_prereq_install() {
    sudo apt-get install libzmq5 libzmq3-dev -y
    sudo apt-get install libzmq3-dev:armhf -y
    sudo apt-get install libsystemd-dev -y
    sudo apt-get install libsystemd-dev:armhf -y
    sudo apt-get install libuuid1:armhf liblz4-1:armhf -y
}

opendht_prereqs_install() {
    sudo apt-get install libncurses5-dev -y
    sudo apt-get install libncurses5-dev:armhf -y
    sudo apt-get install nettle-dev -y
    sudo apt-get install nettle-dev:armhf -y
    echo "installed opendht prerequisites"
}

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

firefox_install() {
    sudo apt-get install firefox -y
    echo "installed firefox"
}

graphviz_install() {
    sudo apt-get install graphviz xdot -y
}

quota_install() {
    sudo apt-get install quota -y
# Do by hand (MM):    sed -i "/vbox--vg-root/c\/dev/mapper/vbox--vg-root / ext4 noatime,errors=remount-ro,usrquota,grpquota 0 1" /etc/fstab
}

riaps_install() {
    # Add RIAPS repository
    sudo add-apt-repository -r "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main" || true
    sudo add-apt-repository -n "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
    sudo cp riaps_install_amd64.sh /home/$1/.
    sudo chown $1:$1 /home/$1/riaps_install_amd64.sh
    sudo -H -u $1 chmod 711 /home/$1/riaps_install_amd64.sh
    ./riaps_install_amd64.sh
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
    sudo -H -u $1 cat "RIAPS:  Add SSH keys to ssh agent on login" >> /home/$1/.bashrc
    sudo -H -u $1 cat "ssh-add /home/$1/.ssh/id_rsa.key" >> /home/$1/.bashrc

    # Setup BBB ssh keys for use with VM
    sudo cp -r bbb_initial_keys /home/$1/.
    sudo chown $1:$1 -R /home/$1/bbb_initial_keys
    sudo -H -u $1 chmod 400 /home/$1/bbb_initial_keys/bbb_initial.key
    sudo -H -u $1 cat "ssh-add /home/$1/bbb_initial_keys/bbb_initial.key" >> /home/$1/.bashrc

    # Transfer BBB rekeying script
    sudo cp secure_keys.sh /home/$1/.
    sudo chown $1:$1 /home/$1/secure_keys.sh
    sudo -H -u $1 chmod 700 /home/$1/secure_keys.sh
    echo "Added user key to authorized keys for $1. Use bbb_initial keys for initial communication with the beaglebones"
}

add_set_tests () {
    sudo -H -u $1 mkdir -p /home/$1/env_setup_tests/WeatherMonitor
    sudo cp -r env_setup_tests/WeatherMonitor /home/$1/env_setup_tests/
    sudo chown $1:$1 -R /home/$1/env_setup_tests/WeatherMonitor
    echo "Added development environment tests"
}

# Start of script actions
set -e
parse_args $@
print_help
user_func
setup_ssh_keys $RIAPSAPPDEVELOPER
cross_setup
vim_func
java_func
cmake_func
utils_install
timesync_requirements
python_install
#eclipse_func $RIAPSAPPDEVELOPER - MM removed, done manually at this time
eclipse_plugin_dep_install
redis_install
curl_func
boost_install
zyre_czmq_prereq_install
opendht_prereqs_install
firefox_install
graphviz_install
quota_install $RIAPSAPPDEVELOPER
add_set_tests $RIAPSAPPDEVELOPER
riaps_install

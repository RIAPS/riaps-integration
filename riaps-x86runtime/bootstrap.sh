#!/usr/bin/env bash

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

# Configure for cross functional compilation
cross_setup() {
    # Add armhf repositories
    sudo apt-get install software-properties-common apt-transport-https -y      
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse"    
    
    # Qualify the architectures for existing repositories trying to find armhf (which is not there) - this is due to issue installing later
    # Need to figure out how not to need this (MM)
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic main restricted" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic main restricted"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic universe"   
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic multiverse"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse" || true
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security main restricted" || true    
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security main restricted"    
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security universe"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu bionic-security multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic main universe multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main universe multiverse"

    
    sudo dpkg --add-architecture armhf
    sudo apt-get update
    sudo apt-get install crossbuild-essential-armhf gdb-multiarch -y
    echo "setup multi-arch capabilities"
}

vim_func() {
    sudo apt-get install vim -y
    echo "installed vim"
}

vscode_install() {
    sudo apt install code -y
    echo "installed vscode"
}

java_func () {    
    sudo apt-get install openjdk-8-jre-headless -y
    echo "installed java"
}

# MM TODO:  may not be necessary, already have gcc/g++ 7.3.0 in image
g++_func() {
    sudo apt-get install gcc g++ -y
    echo "installed g++"
}

# Setup source management tools
# MM TODO:  git is already installed, do we need svn now?
git_svn_func() {
    sudo apt-get install git subversion -y
    echo "installed git and svn"
}

cmake_func() {
    sudo apt-get install cmake -y
    echo "installed cmake"
}

# Required for riaps-timesync
# MM TODO:  pps-tools is already there 
timesync_requirements() {
    sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo "installed timesync requirements"
}

python_install () {
    sudo apt-get install python3-dev python3-pip -y
    sudo pip3 install --upgrade pip 
    sudo pip3 install pydevd
    echo "installed python3 and pydev"
}

cython_install() {
    sudo apt-get install cython3 -y
    echo "installed cython3"
}

curl_func () {
    sudo apt install curl -y
    echo "installed curl"
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
       wget http://riaps.isis.vanderbilt.edu/riaps_eclipse.tar.gz
       tar -xzvf riaps_eclipse.tar.gz
       sudo mv eclipse /home/$1/.
       sudo chown -R $1:$1 /home/$1/eclipse
       sudo -H -u $1 chmod +x /home/$1/eclipse/eclipse
       eclipse_shortcut $1
    else    
	   echo "eclipse already installed at /home/$1/eclipse"
           
    fi
}

redis_install () {
   if [ ! -f "/usr/local/bin/redis-server" ]; then
    wget http://download.redis.io/releases/redis-3.2.5.tar.gz  
    tar xzf redis-3.2.5.tar.gz 
    make -C redis-3.2.5 
    sudo make -C redis-3.2.5 install
    rm -rf redis-3.2.5 
    rm -rf redis-3.2.5.tar.gz 
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

# MM TODO:  update for 18.04 file naming once Vagrant Box is created
quota_install() {
    sudo apt-get install quota -y
    sed -i "/vbox--vg-root/c\/dev/mapper/vbox--vg-root / ext4 noatime,errors=remount-ro,usrquota,grpquota 0 1" /etc/fstab
}

riaps_install() {
    # Add RIAPS repository
    sudo add-apt-repository -r "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main" || true
    sudo add-apt-repository "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ bionic main"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
    sudo chmod +x ./riaps_install_amd64.sh
    ./riaps_install_amd64.sh
}

setup_ssh_keys () {
    sudo -H -u $1 mkdir -p /home/$1/.ssh
    sudo cp $PUBLIC_KEY /home/$1/.ssh/id_rsa.pub
    sudo cp $PRIVATE_KEY /home/$1/.ssh/id_rsa.key
    sudo chown $1:$1 /home/$1/.ssh/id_rsa.pub
    sudo chown $1:$1 /home/$1/.ssh/id_rsa.key
    sudo -H -u $1 cat /home/$1/.ssh/id_rsa.pub >> /home/$1/.ssh/authorized_keys
    sudo chown $1:$1 /home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 400 /home/$1/.ssh/id_rsa.key
    sudo cp -r bbb_initial_keys /home/$1/.
    sudo chown $1:$1 -R /home/$1/bbb_initial_keys
    sudo -H -u $1  chmod 400 /home/$1/bbb_initial_keys/bbb_initial.key
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
#vscode_install - not available in 18.04 yet
java_func
g++_func
git_svn_func
cmake_func
timesync_requirements
python_install
cython_install
eclipse_func $RIAPSAPPDEVELOPER
redis_install
curl_func
firefox_install
graphviz_install
quota_install $RIAPSAPPDEVELOPER
add_set_tests $RIAPSAPPDEVELOPER
riaps_install

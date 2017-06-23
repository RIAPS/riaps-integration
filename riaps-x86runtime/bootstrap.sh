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

    if [ "$PUBLIC_KEY" = "" ] && [ "$PRIVATE_KEY" = "" ] 
    then 
        echo "Please supply a public and private key - public_key=<name>.pub private_key=<name>.key"
    else 
        echo "Found user ssh keys.  Will use them"
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
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER 
        sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
        echo "created user accounts"
    fi    
}

# Configure for cross functional compilation
cross_setup() {
	# Add armhf repositories
	sudo apt-get install software-properties-common -y	
	if grep -q '[arch=armhf] http://ports.ubuntu.com/ubuntu-ports/' /etc/apt/sources.list ; 
	then
        echo "Armhf repositories are already included."
    else
    	sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse"
    	sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main universe multiverse"
    fi
    sudo dpkg --add-architecture armhf
    sudo apt-get update
    sudo apt-get install crossbuild-essential-armhf gdb-multiarch -y
}

vim_func() {
    sudo apt-get install vim -y
    echo "installed vim"
}

java_func () {    
    sudo apt-get install openjdk-8-jre-headless -y
    echo "installed java"
}

g++_func() {
    sudo apt-get install gcc g++ -y
    echo "installed g++"
}

# Setup source management tools
git_svn_func() {
    sudo apt-get install git subversion -y
    echo "installed git and svn"
}

cmake_func() {
    sudo apt-get install cmake -y
    echo "installed cmake"
}

# Required for riaps-timesync
timesync_requirements() {
    sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
}

python_install () {
    sudo apt-get install python3 python3-pip -y
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

eclipse_func() {
    sudo wget http://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/neon/2/eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
    sudo -H -u $1 tar xfz eclipse-java-neon-2-linux-gtk-x86_64.tar.gz -C //home/$1/

    sudo rm eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
    echo "installed eclipse"
}

install_redis () {
    wget http://download.redis.io/releases/redis-3.2.5.tar.gz  
    tar xzf redis-3.2.5.tar.gz 
    make -C redis-3.2.5 
    sudo make -C redis-3.2.5 install
    rm -rf redis-3.2.5 
    rm -rf redis-3.2.5.tar.gz 
}

install_fabric() {
    sudo apt-get install python-pip
    sudo pip2 install fabric
}

install_riaps() {
    # Add RIAPS repository
    if grep -q 'deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main' /etc/apt/sources.list ; 
    then
        echo "RIAPS repository is already included."
    else
    	sudo add-apt-repository "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main"
    fi

    ./riaps_install.sh
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
    sudo -H -u $1 chmod 600 /home/$1/.ssh/id_rsa.key
    sudo cp /home/$1/.ssh/id_rsa.key /usr/local/riaps/keys/id_rsa.key
    sudo cp /home/$1/.ssh/id_rsa.pub /usr/local/riaps/keys/id_rsa.pub
    sudo chown $1:$1 /usr/local/riaps/keys/id_rsa.key
    sudo chown $1:$1 /usr/local/riaps/keys/id_rsa.pub
    sudo -H -u $1 chmod 600 /usr/local/riaps/keys/id_rsa.key
    
    echo "Added user key to authorized keys for $1"
}


# Start of script actions
parse_args $@
print_help
user_func
cross_setup
vim_func
java_func
g++_func
git_svn_func
cmake_func
timesync_requirements
python_install
cython_install
eclipse_func $RIAPSAPPDEVELOPER
install_redis
curl_func
install_riaps
setup_ssh_keys $RIAPSAPPDEVELOPER




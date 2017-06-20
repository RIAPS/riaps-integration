#!/usr/bin/env bash
set -e 

RIAPSAPPDEVELOPER=riaps

check_os_version () {
    # Mary we need to write code here to check OS version and architecture. 
    # The installation should fail if the OS version is not correct.
    true

}

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
        echo "Please supply a public and private key - PUBLIC_KEY=<name>.pub PRIVATE_KEY=<name>.key"
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

# Install RT Kernel
rt_kernel_install() {
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_9
}


user_func () {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        getent group gpio || sudo groupadd gpio
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER 
        sudo usermod -aG dialout $RIAPSAPPDEVELOPER 
        sudo usermod -aG gpio  $RIAPSAPPDEVELOPER 
        sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
        echo "created user accounts"
    fi    
}

vim_func() {
    sudo apt-get install vim -y
    echo "installed vim"
}


g++_func() {
    sudo apt-get install gcc g++ -y
    echo "installed g++"
}

git_svn_func() {
    sudo apt-get install git subversion -y
    echo "installed git and svn"
}

cmake_func() {
    sudo apt-get install cmake -y
    echo "installed cmake"
}

timesync_requirements(){
    sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
}

freqgov_off() {
        touch /etc/default/cpufrequtils
        echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
        update-rc.d ondemand disable
        /etc/init.d/cpufrequtils restart
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

install_riaps(){
    tar -xzvf riaps-release.tar.gz
    sudo dpkg -i riaps-release/riaps-externals-armhf.deb
    echo "installed externals"
    sudo dpkg -i riaps-release/riaps-core-armhf.deb
    echo "installed core"
    sudo dpkg -i riaps-release/riaps-pycom-armhf.deb
    echo "installed pycom"
    sudo dpkg -i riaps-release/riaps-systemd-armhf.deb 
    echo "installed services"
    sudo dpkg -i riaps-release/riaps-timesync-armhf.deb 
    echo "installed timesync"
}

setup_ssh_keys () {
    sudo -H -u $1 mkdir -p /home/$1/.ssh
    
    if [ -f "*.key" ] && [ -f "*.pub" ]
    then
        echo "Found user ssh keys. Will use them"
        
        sudo -H -u $1 cat /usr/local/riaps/keys/id_rsa.pub >> /home/$1/.ssh/authorized_keys
        sudo -H -u $1 cp /usr/local/riaps/keys/id_rsa.key /home/$1/.ssh/.
        chown $1:$1 /home/$1/.ssh/authorized_keys
        chmod 600 /home/$1/.ssh/authorized_keys
        chmod 600 /home/$1/.ssh/id_rsa.key
        echo "Added existing key to authorized keys for $1"
    else
        sudo -H -u $1  ssh-keygen -N "" -q -f /home/$1/.ssh/id_generated_rsa
        echo "generated ssh keys for $1"
        sudo -H -u $1 cat /home/$1/.ssh/id_generated_rsa.pub >>/home/$1/.ssh/authorized_keys
        chown $1:$1 /home/$1/.ssh/authorized_keys
        chmod 600 /home/$1/.ssh/authorized_keys
        echo "Generated new key and added it to authorized keys for $1"
    fi
}

move_key_to_riaps_etc() {
    if [ -f "/usr/local/riaps/keys/id_rsa.key" ] && [ -f "/usr/local/riaps/keys/id_rsa.pub" ]
    then
        echo "keys are setup already in /usr/local/riaps for $1"
    else
        sudo cp /home/$1/.ssh/id_generated_rsa /usr/local/riaps/keys/id_rsa.key
        sudo chown $1:$1 /usr/local/riaps/keys/id_rsa.key
        sudo -H -u $1 chmod 600 /usr/local/riaps/keys/id_rsa.key
        echo "setup keys in /usr/local/riaps for $1"
    fi
}

splash_screen_update() {
    #splash screen
    echo "################################################################################" > motd
    echo "# Acknowledgment:  The information, data or work presented herein was funded   #" >> motd
    echo "# in part by the Advanced Research Projects Agency - Energy (ARPA-E), U.S.     #" >> motd
    echo "# Department of Energy, under Award Number DE-AR0000666. The views and         #" >> motd
    echo "# opinions of the authors expressed herein do not necessarily state or reflect #" >> motd
    echo "# those of the United States Government or any agency thereof.                 #" >> motd
    echo "################################################################################" >> motd
    sudo mv motd /etc/motd
    # Issue.net                                
    echo "Ubuntu 16.04 LTS" > issue.net
    echo "" >> issue.net
    echo "rcn-ee.net console Ubuntu Image 2017-04-07">> issue.net
    echo "">> issue.net
    echo "Support/FAQ: http://elinux.org/BeagleBoardUbuntu">> issue.net
    echo "">> issue.net
    echo "default username:password is [riaps:riaps]">> issue.net
    sudo mv issue.net /etc/issue.net
}

check_os_version
parse_args $@
print_help
rt_kernel_install
user_func
vim_func
g++_func
git_svn_func
cmake_func
timesync_requirements
freqgov_off
python_install
cython_install
curl_func
install_riaps
generate_localkeys $RIAPSAPPDEVELOPER
move_key_to_riaps_etc $RIAPSAPPDEVELOPER
splash_screen_update

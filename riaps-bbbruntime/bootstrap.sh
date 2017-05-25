#!/usr/bin/env bash

RIAPSAPPDEVELOPER=riaps

check_os_version () {
    # Mary we need to write code here to check OS version and architecture. 
    # The installation should fail if the OS version is not correct.
    true

}


# Install RT Kernel
rt_kernel_install() {
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_9
}


user_func () {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; execute below commands to crate and try again:"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER 
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

generate_localkeys () {
    
    sudo -H -u $1  ssh-keygen -N "" -q -f /home/$1/.ssh/id_generated_rsa
    echo "generated ssh keys for $1"
    sudo -H -u $1 cat /home/$1/.ssh/id_generated_rsa.pub >>/home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys  
    echo "Generated new key and added it to authorized keys for $1"
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
}

move_key_to_riaps_etc() {
    sudo cp /home/$1/.ssh/id_generated_rsa /usr/local/riaps/keys/id_rsa.key
    sudo chown $1 /usr/local/riaps/keys/id_rsa.key
    sudo -H -u $1 chmod 600 /usr/local/riaps/keys/id_rsa.key
    echo "setup keys in /usr/local/riaps for $1"

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
rt_kernel_install
user_func
vim_func
g++_func
git_svn_func
cmake_func
timesync_requirements
python_install
cython_install
generate_localkeys $RIAPSAPPDEVELOPER
curl_func
install_riaps
move_key_to_riaps_etc $RIAPSAPPDEVELOPER
splash_screen_update

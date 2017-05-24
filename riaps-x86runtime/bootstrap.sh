#!/usr/bin/env bash

RIAPSAPPDEVELOPER=riaps


user_func () {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; execute below commands to crate and try again:"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER
        echo "created user accounts"
    fi    
}
cross_setup(){
    sudo cp -f sources.list /etc/apt//.
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
git_svn_func() {
    sudo apt-get install git subversion -y
    echo "installed git and svn"
}
cmake_func() {
    sudo apt-get install cmake -y
    sudo apt-get install libssl-dev -y
    echo "installed cmake"
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

move_key_to_riaps_etc() {
    sudo cp /home/$1/.ssh/id_generated_rsa /usr/local/riaps/keys/id_rsa.key
    sudo chown $1 /usr/local/riaps/keys/id_rsa.key
    sudo -H -u $1 chmod 600 /usr/local/riaps/keys/id_rsa.key
    echo "setup keys in /usr/local/riaps for $1"

} 

curl_func () {
    sudo apt install curl -y
    echo "installed curl"
}

install_riaps(){
    tar -xzvf riaps-release.tar.gz
    sudo dpkg -i riaps-release/riaps-externals-amd64.deb
    echo "installed externals"
    sudo dpkg -i riaps-release/riaps-core-amd64.deb
    echo "installed core"
    sudo dpkg -i riaps-release/riaps-pycom-amd64.deb
    echo "installed pycom"
    sudo dpkg -i riaps-release/riaps-systemd-amd64.deb 
    echo "installed services"
}

eclipse_func() {
   
    sudo wget http://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/neon/2/eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
    sudo -H -u $1 tar xfz eclipse-java-neon-2-linux-gtk-x86_64.tar.gz -C //home/$1/

    sudo rm eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
    echo "installed eclipse"
}


user_func
cross_setup
vim_func
java_func
g++_func
git_svn_func
cmake_func
python_install
cython_install
generate_localkeys $RIAPSAPPDEVELOPER
curl_func
install_riaps
move_key_to_riaps_etc $RIAPSAPPDEVELOPER
eclipse_func $RIAPSAPPDEVELOPER


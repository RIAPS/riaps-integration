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

    if [ -z "$PUBLIC_KEY" ] || [ -z "$PRIVATE_KEY" ] 
    then 
        echo "Please supply a public and private key - public_key=<name>.pub private_key=<name>.key"
        exit
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
    sudo apt-get install software-properties-common apt-transport-https -y	
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse"    
    
    # Qualify the architectures for existing repositories trying to find armhf (which is not there) - this is due to issue installing later
    # Need to figure out how not to need this (MM)
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial main restricted" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial main restricted"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial universe"   
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial multiverse"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" || true
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security main restricted" || true    
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security main restricted"    
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security universe" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security universe"
    sudo add-apt-repository -r "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security multiverse" || true
    sudo add-apt-repository "deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu xenial-security multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial main universe multiverse"
    sudo add-apt-repository -r "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main universe multiverse" || true
    sudo add-apt-repository "deb [arch=armhf] http://ports.ubuntu.com/ubuntu-ports/ xenial-updates main universe multiverse"

 
    sudo dpkg --add-architecture armhf
    sudo apt-get update
    sudo apt-get install crossbuild-essential-armhf gdb-multiarch -y
    echo "setup multi-arch capabilities"
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
    echo "installed timesync requirements"
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


eclipse_shortcut() {
   shortcut=/home/$1/Desktop/Eclipse.desktop
   sudo -H -u $1 mkdir -p /home/$1/Desktop
   sudo -H -u $1 cat <<EOT >$shortcut
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Eclipse
Name[en_US]=Eclipse
Icon=/opt/eclipse/icon.xpm
Exec=/opt/eclipse/eclipse -data /home/$1/workspace
EOT

   sudo chmod +x /home/$1/Desktop/Eclipse.desktop
}

eclipse_func() {
    if [ ! -f "/home/$1/eclipse/eclipse" ]
    then
	if [ ! -f "/opt/eclipse/eclipse" ]
    	then
            echo "eclipse not found"
            sudo wget http://ftp.osuosl.org/pub/eclipse/technology/epp/downloads/release/neon/2/eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
            sudo tar xfz eclipse-java-neon-2-linux-gtk-x86_64.tar.gz -C /opt
            #create eclipse shortcut
            eclipse_shortcut $1
            #install plugins
            sudo /opt/eclipse/eclipse -clean  -consolelog  -noSplash -application org.eclipse.equinox.p2.director -repository http://pydev.org/updates -installIU "org.python.pydev.feature.feature.group, org.python.pydev.mylyn.feature.feature.group, org.python.pydev.feature.source.feature.group"    
            #GIT
            sudo /opt/eclipse/eclipse -clean  -consolelog  -noSplash -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/neon/ -installIU "org.eclipse.egit.feature.group, org.eclipse.jgit.feature.group"	
            #JSON Editor
            sudo /opt/eclipse/eclipse -clean  -consolelog  -noSplash -application org.eclipse.equinox.p2.director -repository http://boothen.github.io/Json-Eclipse-Plugin/ -installIU "jsonedit-feature.feature.group"	
            #Subclipse
            sudo /opt/eclipse/eclipse -clean  -consolelog  -noSplash -application org.eclipse.equinox.p2.director -repository https://dl.bintray.com/subclipse/releases/subclipse/latest/ -installIU "org.tigris.subversion.subclipse.feature.group, net.java.dev.jna.feature.group, org.tigris.subversion.subclipse.mylyn.feature.feature.group, org.tigris.subversion.subclipse.graph.feature.feature.group, org.tigris.subversion.clientadapter.svnkit.feature.feature.group, org.tmatesoft.svnkit.feature.group"
            sudo rm eclipse-java-neon-2-linux-gtk-x86_64.tar.gz
            echo "installed eclipse"
        else
            echo "eclipse already installed at /opt/eclipse"
        fi
    else
    echo "eclipse already installed at /home/riaps/eclipse"
        
    fi
}

install_redis () {
    wget http://download.redis.io/releases/redis-3.2.5.tar.gz  
    tar xzf redis-3.2.5.tar.gz 
    make -C redis-3.2.5 
    sudo make -C redis-3.2.5 install
    rm -rf redis-3.2.5 
    rm -rf redis-3.2.5.tar.gz 
    echo "installed redis"
}

install_fabric() {
    sudo apt-get install python-pip
    sudo pip2 install fabric
    echo "installed fabric"
}

install_riaps() {
    # Add RIAPS repository
    sudo add-apt-repository -r "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main" || true
    sudo add-apt-repository "deb [arch=amd64] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main"
    wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | sudo apt-key add -
    sudo apt-get update
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
install_fabric
install_riaps
setup_ssh_keys $RIAPSAPPDEVELOPER




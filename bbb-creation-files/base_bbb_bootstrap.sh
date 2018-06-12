#!/usr/bin/env bash
set -e 

# Script Variables
RIAPSAPPDEVELOPER=riaps

# Script functions
check_os_version() {
    # Mary we need to write code here to check OS version and architecture. 
    # The installation should fail if the OS version is not correct.
    true

}

# Install RT Kernel
rt_kernel_install() {
    sudo /opt/scripts/tools/update_kernel.sh --ti-rt-kernel --lts-4_9
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
        echo "created user accounts"
    fi    
}

# Needed for BBB clusters to allow apt-get update to work properly
rdate_install() {
    sudo apt-get install rdate -y
    sudo rdate -n -4 time.nist.gov
    echo "installed rdate"
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

timesync_requirements() {
    sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo "installed timesync requirements"
}

freqgov_off() {
    touch /etc/default/cpufrequtils
    echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
    update-rc.d ondemand disable
    /etc/init.d/cpufrequtils restart
    echo "setup frequency and governor"
}

python_install() {
    sudo apt-get install python3-dev python3-pip -y
    sudo pip3 install --upgrade pip 
    sudo pip3 install pydevd
    echo "installed python3 and pydev"
}

cython_install() {
    sudo apt-get install cython3 -y
    echo "installed cython3"
}

curl_func() {
    sudo apt install curl -y
    echo "installed curl"
}

# Remove Apache from the original base image
rm_apache() {
    sudo apt-get remove --purge apache2* -y
    echo "removed apache"
}

# Add watchdog timers
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
    sed -i "/mmcblk0p1/c\/dev/mmcblk0p1 / ext4 noatime,errors=remount-ro,usrquota,grpquota 0 1" /etc/fstab
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
    echo "rcn-ee.net console Ubuntu Image 2018-03-09">> issue.net
    echo "">> issue.net
    echo "Support/FAQ: http://elinux.org/BeagleBoardUbuntu">> issue.net
    echo "">> issue.net
    echo "default username:password is [riaps:riaps]">> issue.net
    sudo mv issue.net /etc/issue.net
    echo "setup splash screen"
}

setup_hostname() {
    cp usr/bin/set_unique_hostname /usr/bin/set_unique_hostname
    cp etc/systemd/system/sethostname.service /etc/systemd/system/.
    systemctl daemon-reload
    systemctl start sethostname.service
    systemctl enable sethostname.service 
    echo "setup hostname"
}

setup_peripherals() {
    cp etc/profile.d/20-riaps-gpio.sh /etc/profile.d/20-riaps-gpio.sh
    cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
    
    getent group gpio ||groupadd gpio
    getent group dialout ||groupadd dialout
    getent group pwm ||groupadd pwm

    udevadm trigger --subsystem-match=gpio
    echo "setup peripherals - gpio, uart, and pwm"
}

setup_network() {
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

setup_riaps_repo() {
    sudo apt-get install software-properties-common apt-transport-https -y
	
    # Add RIAPS repository
    echo "add repo to sources"
    sudo add-apt-repository -r "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main" || true
    sudo add-apt-repository "deb [arch=armhf] https://riaps.isis.vanderbilt.edu/aptrepo/ xenial main"    
    echo "get riaps public key"
    wget -q --no-check-certificate - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key
    echo "adding riaps public key"
    sudo apt-key add riapspublic.key
    sudo apt-get update
    echo "riaps aptrepo setup"
}

# Pre-install packages that take a long time compiling on the BBBs to minimize user RIAPS installation time
pre_install_riaps_pkgs() {
    CFLAGS=-I/opt/riaps/armhf/include LDFLAGS=-L/opt/riaps/armhf/lib PATH=$PATH:/opt/riaps/armhf/bin sudo pip3 install 'pycapnp==0.5.12' --verbose
    sudo pip3 install 'paramiko==2.2.1' 'cryptography==1.9' --verbose
}

# This function requires that bbb_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/bbb_initial_keys/id_rsa.pub
# be placed on the bbb as this script is run
setup_ssh_keys() {
    sudo -H -u $1 mkdir -p /home/$1/.ssh
    sudo cp bbb_initial_keys/bbb_initial.pub /home/$1/.ssh/bbb_initial.pub
    sudo chown $1:$1 /home/$1/.ssh/bbb_initial.pub
    sudo -H -u $1 cat /home/$1/.ssh/bbb_initial.pub >> /home/$1/.ssh/authorized_keys
    sudo chown $1:$1 /home/$1/.ssh/authorized_keys
    sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys
    
    echo "Added unsecured public key to authorized keys for $1"
}

# Start of script actions
check_os_version
rt_kernel_install
user_func
rdate_install
vim_func
g++_func
git_svn_func
cmake_func
timesync_requirements
freqgov_off
python_install
cython_install
curl_func
rm_apache
watchdog_timers
quota_install $RIAPSAPPDEVELOPER
splash_screen_update
setup_hostname
setup_peripherals
setup_network
pre_install_riaps_pkgs
setup_ssh_keys $RIAPSAPPDEVELOPER
setup_riaps_repo
#!/usr/bin/env bash

RIAPSAPPDEVELOPER=riaps
sethostname=bin/set_unique_hostname.py
sethostservice=conf/sethostname.service
gpiorule=etc_udev/80-non-root-gpio-permissions.rules


if [ -f "setup.conf" ]
then
  echo "Found setup.conf"
else
  echo "Cannot find setup.conf"
  exit 1
fi
source setup.conf
source .bashrc

# Install RT Kernel
rt_kernel_install() {
	sudo apt-get install linux-image-4.4.12-ti-rt-r30 linux-firmware-image-4.4.12-ti-rt-r30 linux-headers-4.4.12-ti-rt-r30 -y
}

# Set hostname to bbb-xxxx, where xxxx is the last 4 digits of the MAC address
hostname_setup() {
	sudo mkdir -p /opt/riaps/armhf/bin
	sudo cp $sethostname /opt/riaps/armhf/bin
	sudo cp $sethostservice /etc/systemd/system
	sudo systemctl enable sethostname.service	
	sudo systemctl daemon-reload
}

# Setup user account
user_func() {	 
	sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
	sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
	 
	sudo usermod -aG sudo $RIAPSAPPDEVELOPER
}

# Install ssh keys from setup.conf
install_riaps_keys() {
	  sudo -H -u $1 touch /home/$1/.ssh/authorized_keys
	  sudo -H -u $1 cat $SSH_PUBLIC_KEY >> /home/$1/.ssh/authorized_keys	
	  sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys  
	  sudo -H -u $1 touch /home/$1/.ssh/id_rsa
	  sudo -H -u $1 cat $SSH_PRIVATE_KEY >> /home/$1/.ssh/id_rsa 
	  sudo -H -u $1 chmod 600 /home/$1/.ssh/id_rsa	 
	  sudo -H -u $1 ssh-agent /bin/bash
	  sudo -H -u $1 ssh-add /home/$1/.ssh/id_rsa
}

# Setup any system utilities
utilities_setup() {
    sudo apt-get install python3 python3-pip python3-dev -y
	sudo pip3 install --upgrade pip 
	sudo apt-get install tmux gdbserver -y
	sudo pip3 install influxdb pydevd
}

# Install Random Number Generator used by RIAPS Discovery Service
randomnum_install() {
	sudo apt-get install rng-tools -y
	sudo systemctl enable rng-tools.service	
}

# Turn off Frequency Governing
freqgov_off() {
	sudo touch /etc/default/cpufrequtils
	sudo cat 'GOVERNOR="performance"' > /etc/default/cpufrequtils
	sudo update-rc.d ondemand disable
	sudo /etc/init.d/cpufrequtils restart
}

# HW Device Specific Configurations
# Components installed:  GPIO, Modbus (UART)
# Note:  minimalmodbus installs pyserial
hwconfig_setup() {
	if [$SLOTS eq ""]
	then
		sudo -H -u $1 echo "export SLOTS=/sys/devices/platform/bone_capemgr/slots" >> /home/$1/.bashrc  
		
	if [$PINS eq ""]
	then
		sudo -H -u $1 echo "export PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins" >> /home/$1/.bashrc  
		
	# add 'riaps' to device output groups
	sudo groupadd gpio
	sudo -H -u $1 usermod -a -G dialout $1
	sudo -H -u $1 usermod -a -G gpio $1
	sudo cp $gpiorule /etc/udev/rules.d
	sudo chmod 744 /etc/udev/rules.d/$gpiorule
	
	# Update visudo to retain the environment variables on a su call
	sudo sh -c "echo \"Defaults    env_keep += \"SLOTS\"\" >> /etc/sudoers"
	sudo sh -c "echo \"Defaults    env_keep += \"PINS\"\"  >> /etc/sudoers"
	
	# Packages used by Device Components 
	sudo pip3 install Adafruit_BBIO minimalmodbus
}

# Remove unnecessary packages that may interfere
unneeded_removal() {
	sudo apt-get remove connman
}

# RIAPS Specified Middleware
middleware_install() {
	sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y 
	sudo apt-get install libcapnp-dev libssl-dev libffi-dev -y
    sudo pip3 install 'pyzmq>=16' 'textX>=1.4' 'pycapnp >= 0.5.9' 'netifaces>=0.10.5' 'paramiko>=2.0.2' 'cryptography>=1.5.3'
    sudo pip3 install git+https://github.com/adubey14/rpyc#egg=rpyc-3.3.1
}

# Install RIAPS deb packages
riapsdeb_install() {
	sudo ../install_integration.sh
}


rt_kernel_install
echo "RT kernel installed"
hostname_setup
echo "BBB hostname configured"
user_func 
echo "Created riaps user account"
install_riaps_keys $RIAPSAPPDEVELOPER
echo "Installed riaps user key"
utilities_setup
echo "System utilities setup"
randomnum_install
echo "Random number generator installed"
freqgov_off
echo "Turn off frequency governing"
hwconfig_setup $RIAPSAPPDEVELOPER
echo "HW device specific configurations done"
unneeded_removal
echo "Removed unneeded packages"
middleware_install
echo "Installed RIAPS required middleware"
riapsdeb_install
echo "RIAPS deb packages installed"
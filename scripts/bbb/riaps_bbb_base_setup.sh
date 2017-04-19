#!/usr/bin/env bash
set -e

RIAPSAPPDEVELOPER=riaps
sethostname=bin/set_unique_hostname.py
sethostservice=conf/sethostname.service
gpiorule_dir=etc/udev/rules.d/
gpiorule=80-non-root-gpio-permissions.rules
kernelupdate=/opt/scripts/tools/update_kernel.sh
riapsdisclaimer=etc/motd
riapshint=etc/issue.net


if [ -f "../setup.conf" ]
then
  echo "Found setup.conf"
else
  echo "Cannot find setup.conf"
  exit 1
fi
source ../setup.conf


# Install RT Kernel
rt_kernel_install() {
	sudo $kernelupdate --ti-rt-kernel --lts-4_9
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
	sudo echo -e "riapspwd\nriapspwd" | sudo passwd $RIAPSAPPDEVELOPER
	 
	sudo usermod -aG sudo $RIAPSAPPDEVELOPER
}

# Configure the login information
splash_screen_update() {
	sudo cp $riapsdisclaimer /etc
	sudo cp $riapshint /etc
}

# Install ssh keys from setup.conf
install_riaps_keys() {
	sudo -H -u $1 mkdir -p /home/$1/.ssh
	sudo -H -u $1 touch /home/$1/.ssh/authorized_keys
	sudo -H -u $1 chmod 777 /home/$1/.ssh/authorized_keys
	sudo -H -u $1 cat ../$SSH_PUBLIC_KEY >> /home/$1/.ssh/authorized_keys	
 	sudo -H -u $1 cp ../$SSH_PUBLIC_KEY /home/$1/.ssh/
	sudo -H -u $1 chmod 600 /home/$1/.ssh/authorized_keys  
	sudo -H -u $1 cp ../$SSH_PRIVATE_KEY /home/$1/.ssh/$SSH_PRIVATE_KEY
	sudo -H -u $1 chmod 600 /home/$1/.ssh/$SSH_PRIVATE_KEY	 
# Note:  This was used in the manual build of the BBB image, but purposely leaving it out now
#	sudo -H -u $1 ssh-agent /bin/bash
#	sudo -H -u $1 ssh-add /home/$1/.ssh/$SSH_PRIVATE_KEY
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
	sudo systemctl start rng-tools.service	
}

# Turn off Frequency Governing
freqgov_off() {
	sudo touch /etc/default/cpufrequtils
	echo "GOVERNOR=\"performance\"" | sudo tee -a /etc/default/cpufrequtils
	sudo update-rc.d ondemand disable
	sudo /etc/init.d/cpufrequtils restart
}

# HW Device Specific Configurations
# Components installed:  GPIO, Modbus (UART)
# Note:  minimalmodbus installs pyserial
hwconfig_setup() {
	source /home/riaps/.bashrc

	if [$SLOTS eq ""]
	then
		echo -en "\n# RIAPS Device Slots\nexport SLOTS=/sys/devices/platform/bone_capemgr/slots\n" | sudo tee -a /home/riaps/.bashrc
	fi
		
	if [$PINS eq ""]
	then
		echo -en "\n# RIAPS Device Pins\nexport PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins\n" | sudo tee -a /home/riaps/.bashrc  
	fi
		
	# add 'riaps' to device output groups
	sudo groupadd gpio
	sudo usermod -aG dialout $1
	sudo usermod -aG gpio $1
	sudo cp $gpiorule_dir$gpiorule /etc/udev/rules.d
	sudo chmod 644 /etc/udev/rules.d/$gpiorule
	
	# Update visudo to retain the environment variables on a su call
	sudo sh -c "echo \" \" >> /etc/sudoers"
	sudo sh -c "echo \"# Persist device interface environment variables\" >> /etc/sudoers"
	sudo sh -c "echo \"Defaults    env_keep += \"SLOTS\"\" >> /etc/sudoers"
	sudo sh -c "echo \"Defaults    env_keep += \"PINS\"\"  >> /etc/sudoers"
	
	# Packages used by Device Components 
	sudo pip3 install Adafruit_BBIO minimalmodbus
}

# Remove unnecessary packages that may interfere
unneeded_removal() {
# MM TODO:  is this needed?	sudo apt-get remove connman -y
	echo "Nothing to remove at this time"
}

# RIAPS Specified Middleware
middleware_install() {
	sudo apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y 
	sudo apt-get install libcapnp-dev libssl-dev libffi-dev -y
    sudo pip3 install 'redis>=2.10.5' 'hiredis >= 0.2.0'  # expect to remove soon (MM)
    sudo pip3 install 'pyzmq>=16' 'textX>=1.4' 'pycapnp >= 0.5.9' 'netifaces>=0.10.5' 'paramiko>=2.0.2' 'cryptography>=1.5.3'
    sudo -H pip3 install git+https://github.com/adubey14/rpyc #egg=rpyc-3.3.1
}

# Install RIAPS deb packages
riapsdeb_install() {
	sudo ../download_packages.sh
	sudo ../install_integration.sh
}

# Cleanup after installation
remove_installartifacts() {
	rm -r scripts
	rm scripts.tar.gz
}


rt_kernel_install
echo "RT kernel installed"
hostname_setup
echo "BBB hostname configured"
user_func 
echo "Created riaps user account"
splash_screen_update
echo "Splash screen updated"
install_riaps_keys $RIAPSAPPDEVELOPER
echo "Installed riaps user key"
utilities_setup
echo "System utilities setup"
randomnum_install
echo "Random number generator installed"
freqgov_off
echo "Frequency governing is turned off"
hwconfig_setup $RIAPSAPPDEVELOPER
echo "HW device specific configurations done"
unneeded_removal
echo "Removed unneeded packages"
middleware_install
echo "Installed RIAPS required middleware"
riapsdeb_install
echo "RIAPS deb packages installed"
remove_installartifacts
echo "Cleanup after installation done"
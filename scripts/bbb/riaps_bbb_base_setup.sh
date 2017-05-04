#!/usr/bin/env bash

set -e

# Variable Declarations
RIAPSAPPDEVELOPER=riaps
sethostname=bin/set_unique_hostname.py
sethostservice=conf/sethostname.service
gpiorule_dir=etc/udev/rules.d/
gpiorule=80-gpio-noroot.rules
# MM TODO:  delete after retesting that this new rule works gpiorule=80-non-root-gpio-permissions.rules
kernelupdate=/opt/scripts/tools/update_kernel.sh
riapsdisclaimer=etc/motd
riapshint=etc/issue.net
netinterface=etc/network/interfaces
resolv=etc/resolv.conf


# Look for correct credentials before installing
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
	$kernelupdate --ti-rt-kernel --lts-4_9
}

# Set hostname to bbb-xxxx, where xxxx is the last 4 digits of the MAC address
hostname_setup() {
	mkdir -p /opt/riaps/armhf/bin
	cp $sethostname /opt/riaps/armhf/bin
	cp $sethostservice /etc/systemd/system
	systemctl enable sethostname.service	
	systemctl daemon-reload
}

# Setup user account
user_func() {	 
	set +e
	grep riaps /etc/passwd
	status=$?
	if [ $status -eq "1" ]
	then
		useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
		echo -e "riapspwd\nriapspwd" | sudo passwd $RIAPSAPPDEVELOPER	 
		usermod -aG sudo $RIAPSAPPDEVELOPER
	else
	    echo "riaps user already exists"
	fi
	set -e
}

# Configure the login information
splash_screen_update() {
	cp $riapsdisclaimer /etc
	cp $riapshint /etc
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
    apt-get install python3 python3-pip python3-dev -y
	pip3 install --upgrade pip 
	apt-get install tmux gdbserver -y
	pip3 install influxdb pydevd
}

# Install Random Number Generator used by RIAPS Discovery Service
randomnum_install() {
	apt-get install rng-tools -y
	systemctl start rng-tools.service	
}

# Turn off Frequency Governing
freqgov_off() {
	touch /etc/default/cpufrequtils
	echo "GOVERNOR=\"performance\"" | tee -a /etc/default/cpufrequtils
	update-rc.d ondemand disable
	/etc/init.d/cpufrequtils restart
}

# Specify Network Interface to have Ethernet enable
interface_update() {
    cp $netinterface /etc/network/interfaces
    cp $resolv /etc/resolv.conf
	# MM TODO:  consider adding the follow item
	#echo -en "\n# RIAPS Network Setup\n/sbin/route add default gw 192.168.7.1\n" | sudo tee -a /home/riaps/.bashrc
}
	
# HW Device Specific Configurations
# Components installed:  GPIO, Modbus (UART)
# Note:  minimalmodbus installs pyserial
hwconfig_setup() {
	source /home/riaps/.bashrc

    # Setup for GPIO
	if [$SLOTS eq ""]
	then
		echo -en "\n# RIAPS Device Slots\nexport SLOTS=/sys/devices/platform/bone_capemgr/slots\n" | sudo tee -a /home/riaps/.bashrc
	fi
		
	if [$PINS eq ""]
	then
		echo -en "\n# RIAPS Device Pins\nexport PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins\n" | sudo tee -a /home/riaps/.bashrc  
	fi
		
	# add 'riaps' to device output groups
	set +e
	grep gpio /etc/group
	status=$?
	if [ $status -eq "1" ]
	then
	    groupadd gpio
	    usermod -aG dialout $1
	    usermod -aG gpio $1
	else
	    echo "gpio group already exists"
	fi
	set -e

	cp $gpiorule_dir$gpiorule /etc/udev/rules.d
	chmod 644 /etc/udev/rules.d/$gpiorule
	udevadm trigger --subsystem-match=gpio
	# MM TODO:  try trigger instead --> udevadm control --reload-rules
	
	# Update visudo to retain the environment variables on a su call
    sh -c "echo \"# Persist device interface environment variables \nDefaults    env_keep += \"SLOTS\" \nDefaults    env_keep += \"PINS\"\" > /etc/sudoers.d/riaps"
	
	# Packages used by Device Components 
	pip3 install Adafruit_BBIO minimalmodbus
}

# RIAPS Specified Middleware
middleware_install() {
	apt-get install pps-tools linuxptp libnss-mdns gpsd gpsd-clients chrony -y 
	apt-get install libssl-dev libffi-dev -y
    # MM TODO: Removed - let happen in integration script 
    #pip3 install 'redis>=2.10.5' 'hiredis >= 0.2.0'  # expect to remove soon (MM)
    #pip3 install 'pyzmq>=16' 'textX>=1.4' 'pycapnp >= 0.5.9' 'netifaces>=0.10.5' 'paramiko>=2.0.2' 'cryptography>=1.5.3'
    #pip3 install git+https://github.com/adubey14/rpyc #egg=rpyc-3.3.1
}

# Install RIAPS deb packages
riapsdeb_install() {
	../install_integration.sh arch="armhf" release_dir="../riaps-release"
}

# Cleanup after installation
remove_installartifacts() {
	rm -r /home/ubuntu/install_files
}

# This package is installed in the base image and controls the network interface in ways we do not desire. 
# Once it is removed, the network interface is lost.  So, this should be the very last step taken.
# This reboot will also allow execute the hostname and udev rules (services setup to run on bootup)
remove_connman() {
    sudo dpkg --remove conman -y
    sudo reboot
}


# Start Function Calls
echo "`date -u` - Start installation" 
rt_kernel_install
echo "`date -u` - RT kernel installed" 
hostname_setup
echo "`date -u` - BBB hostname configured" 
user_func 
echo "`date -u` - Created riaps user account" 
splash_screen_update
echo "`date -u` - Splash screen updated" 
install_riaps_keys $RIAPSAPPDEVELOPER
echo "`date -u` - Installed riaps user key" 
utilities_setup
echo "`date -u` - System utilities setup" 
randomnum_install
echo "`date -u` - Random number generator installed" 
freqgov_off
echo "`date -u` - Frequency governing is turned off" 
#interface_update
echo "`date -u` - Turn on Ethernet port" 
hwconfig_setup $RIAPSAPPDEVELOPER
echo "`date -u` - HW device specific configurations done" 
middleware_install
echo "`date -u` - Installed RIAPS required middleware" 
riapsdeb_install
echo "`date -u` - RIAPS deb packages installed" 
remove_installartifacts
echo "`date -u` - Cleanup after installation done" 
echo "Removing connman ... the network connection will be lost and the BBB will reboot"
echo "When bootup is complete, the riaps login and bbb-xxxx.local hostname will be available for ssh"
#remove_connman

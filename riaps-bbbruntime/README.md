# How to Create a BBB Base Image from Ubuntu Pre-configured Image

This work should be done on a Linux machine or VM.  We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1. Download a complete pre-configured image (Ubuntu 16.04) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1)

    ```
    wget https://rcn-ee.com/rootfs/2017-04-07/elinux/ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz
    ```

2. Unpack image and change into the directory

    ```
    tar xf ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz
    cd ubuntu-16.04.2-console-armhf-2017-04-07
    ```

    ```
    Username:  ubuntu
    Password:  temppwd
    Kernel:    v4.9.xx-ti-rxx (with real-time features)
    ```

3. Locate the SD Card on the Linux machine, looking for the appropriate /dev/sdX (i.e. /dev/sdb)

    ```
    sudo ./setup_sdcard.sh --probe-mmc
    ```
  
4. Install image on SD card, where /dev/sdX is the location of the SD Card 

    ```
    sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone
    ```
  
# Installation of RIAPS on Pre-configured BBB 

1. With the SD Card installed in the BBB, log into the BBB using ssh with user account being '**ubuntu**'

2. Download the latest released installation package (riaps-bbbruntime.tar.gz) from https://github.com/RIAPS/riaps-integration/releases to the BBB.  See the helpful hints section below for ideas on how best to get this image to the BBB.

3. On the BBB, unpack the installation and move into the package

	```
	tar xf riaps-bbbruntime.tar.gz
	cd riaps-bbbruntime
	```

4. Download your rsa ssh key pair (.pub and .key) to the BBB in the '/home/ubuntu/riaps-bbbruntime/' directory.  If you need to generate keys, use the following command.  The same key pair should be used on the BBB and the host development machine (VM).

	```
	cat id_generated_rsa >> authorized_keys
	```

5. Move to 'root' user
	
	```
	sudo su   
	```	   
		
6. Run the installation script.  Provide the name of the ssh key pair added in step 5, your key filename can be any name desired.  The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received.  If you have any issues during installation, this is a good file to send with your questions.
	
	```
	./bootstrap.sh public_key=id_rsa.pub private_key=id_rsa.key 2>&1 | tee install-bbb.log
	```	
	
7. Reboot the Beaglebone Black

	```
	sudo reboot   
	```
	
8. When the BBB is rebooted, you can ssh using the following:

	```
	Username:  riaps
	Password:  riaps
	```
	
# Update RIAPS Packages on Existing BBBs

1. Download the RIAPS releases (riaps-release.tar.gz found at https://github.com/RIAPS/riaps-integration/releases), unzip it and change into that directory in the command line window.

2. Download the RIAPS update script (https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install.sh) to the BBB

3. Run the update script

	```
	./riaps_install.sh 2>&1 | tee install-riaps-update-bbb.log
	```

# Helpful Hints 

1. You can download the latest release to your VM and then 'scp' it over to the BBB using the following, substituting the 192.168.1.xxx with the IP address of your BBB
    
	```
    scp riaps-bbbruntime.tar.gz ubuntu@192.168.1.xxx:
	```
	
2. If you try 'scp' or 'ssh' and receive the following message, remove the '~/.ssh/known_host' file and try again.

 	```
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
	Someone could be eavesdropping on you right now (man-in-the-middle attack)!
	It is also possible that a host key has just been changed.
	The fingerprint for the ECDSA key sent by the remote host is
	SHA256:mX09UKLFyvo51pwSzd5IUapUlUVSxhPZZDZqGlBy4RY.
	Please contact your system administrator.
	Add correct host key in /home/riaps/.ssh/known_hosts to get rid of this message.
	Offending ECDSA key in /home/riaps/.ssh/known_hosts:2
	  remove with:
	  ssh-keygen -f "/home/riaps/.ssh/known_hosts" -R 192.168.1.101
	ECDSA host key for 192.168.1.101 has changed and you have requested strict checking.
	Host key verification failed.
	lost connection
	```
	

# Available RIAPS Services

Current services loaded into the image on the BBB and on the host VM:

1. riaps-disco.service - will start the RIAPS discovery application.  This service should be started first and stopped last.  When enabled, this service is setup to restart when it fails.
    
   - this service is currently disabled by default 

2. riaps-deplo.service - will start the RIAPS deployment application.  This service should be started after riaps-disco.service.  If riaps-disco.service is not running, this service will fail due to dependencies.  When enabled, this service is setup to restart when it or riaps-disco.service fails.

   - this service is currently disabled by default

To see the status of a service or control its state, use the following commands manually on a command line, where name is the service name (like disco).  Starting a service runs the actions immediately.  Enabling the service will allow the service to start when booting up.

	```
   sudo systemctl status riaps-<name>.service
   sudo systemctl start riaps-<name>.service
   sudo systemctl stop riaps-<name>.service
   sudo systemctl enable riaps-<name>.service
   sudo systemctl disable riaps-<name>.service
   ```
 NOTE: a fabfile will be provided in the near future to make things easier to turn on and off
   

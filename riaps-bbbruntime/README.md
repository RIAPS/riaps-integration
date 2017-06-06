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
   If you want to use your own private ssh keys to make things more secure, copy your rsa ssh key pair (.pub and .key) into 
   this directory. Otherwise, a default set of keys will be utilized.  

4. Move to 'root' user
	
	```
	sudo su   
	```	   
	
5. Run the installation script
	
	```
	./bootstrap.sh   
	```	
	
6. Reboot the Beaglebone Black

	```
	sudo reboot   
	```
	
# Helpful Hints 

1. You can download the latest release to your VM and then 'scp' it over to the BBB using the following:
    
    	```
    	scp riaps-bbbruntime.tar.gz ubuntu@192.168.1.xxx:   <using the IP address of your BBB>
   	```
	
2. If you try 'scp' or 'ssh' and receive the following message, remove the '~/.ssh/known_host' file and try again.

    	```
	riaps@riapsvboxmm:~/Downloads$ scp riaps-bbbruntime.tar.gz ubuntu@192.168.1.101:
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
	
3.  If you want to use your own generated SSH keys (from the VM), scp over the public key to the BBB and place in '~/.ssh' directory.  Then add the public key (example name below of id_generated_rsa) to the authorized_key file.  You may need this to transfer application from the 'riaps_ctrl' on the host VM to the BBB if you get an application download fault indication.

	```
	cd ~/.ssh
	cat id_generated_rsa >> authorized_keys
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
   

# How to Create a BBB Base Image from Ubuntu Pre-configured Image

This work should be done on a Linux machine or VM.  We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1. Download a complete pre-configured image (Ubuntu 16.04) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1)

    ```
    wget https://rcn-ee.com/rootfs/2017-04-07/elinux/ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz
    ```

2. Unpack image

    ```
  	tar xf ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz
  	cd ubuntu-16.04.2-console-armhf-2017-04-07
  	```

  Username:  ubuntu
  Password:   temppwd
  Kernel:  v4.4.59-ti-r96 kernel (updated on 2017-04-07)

3. Locate the SD Card on the Linux machine, looking for the appropriate /dev/sdX (i.e. /dev/sdb)

  	```
    sudo ./setup_sdcard.sh --probe-mmc
  	```
  
4. Install image on SD card, where /dev/sdX is the location of the SD Card 

  	```
    sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone
  	```
  
# Installation of RIAPS on Pre-configured BBB 

1. With the SD Card installed in the BBB, log into the BBB using ssh with user account being 'ubuntu'

2. Download the latest released installation package (riaps-bbbruntime.tar.gz) from https://github.com/RIAPS/riaps-integration/releases to the BBB
    
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
   

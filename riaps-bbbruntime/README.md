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

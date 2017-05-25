# How to Create a BBB from Ubuntu Pre-configured Image

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

3. Locate the SD Card on the Linux machine

  	```
    sudo ./setup_sdcard.sh --probe-mmc
  	```
  
4. Install image on SD card

  	```
    sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone
  	```
  
# Installation of RIAPS on Pre-configured BBB 

1. Download the latest released installation package (riaps-bbbruntime.tar.gz) from https://github.com/RIAPS/riaps-integration/releases
    
    
2. Unpack the installation and move into the package

	```
	tar xf riaps-bbbruntime.tar.gz
	cd riaps-bbbruntime
	```

3. Move to 'root' user
	
	```
	sudo su   
	```	   
	
4. Run the installation script
	
	```
	./bootstrap.sh   
	```	   

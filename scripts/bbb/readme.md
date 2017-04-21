# BBB Folder Contents

This folder contains beaglebone specific installation scripts.  

  * fabfile_bbb.py is used for installations and updates from a Linux VM to the BBBs
  * 

# How to Create a BBB from Ubuntu Pre-configured Image

This work should be done on a Linux machine or VM.  We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1. Download a complete pre-configured image (Ubuntu 16.04) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1)

  `wget https://rcn-ee.com/rootfs/2017-04-07/elinux/ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz`

2. Unpack image

  ```
  tar xf ubuntu-16.04.2-console-armhf-2017-04-07.tar.xz`
  cd ubuntu-16.04.2-console-armhf-2017-04-07
  ```

  Username:  ubuntu
  Password:   temppwd
  Kernel:  v4.4.59-ti-r96 kernel (updated on 2017-04-07)

3. Locate the SD Card on the Linux machine

  `sudo ./setup_sdcard.sh --probe-mmc`
  
4. Install image on SD card

  `sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone`

5. Download the needed files for installation
    
    $ git clone riaps-integration
    
6. Pull the latest RIAPS software to the VM

	$ ./download_packages.sh arch="armhf" version_conf="../version.sh" setup_conf="setup.conf"
	
	where version_conf and setup_conf point to the locations of the files.  
	'version.sh' is configured in the repository with the latest releases.
	'setup.conf' is customized to the person downloading (containing reference to locations of SSH and GITHUB OAUTH keys).  Only an example of this file will located in the riaps-integration repository.  User will need to edit this file for their setup. 
	    
7. Using 'fabfile_bbb.py' either do a full installation on the BBB (the first time) or an update when desired
	
	$ fab -f fabfile_bbb.py bbb_full_install   
	   
	            or
	            
	$ fab -f fabfile_bbb.py bbb_install_update  	
	
	Note:  Fabric must be installed on the VM (sudo pip install fabric).  This is a python2 script.  
	This fabric file should be configured to work with your particular VM.  This example is connection to a specific VM addressable only by the testing VM.
	
	  `env.hosts = ['192.168.1.102']`


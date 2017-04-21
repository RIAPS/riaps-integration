This folder contains beaglebone specific installation scripts

In a Linux VM:
1) Download the needed files for installation
    
    $ git clone riaps-integration
    
2) Pull the latest RIAPS software to the VM

	$ ./download_packages.sh arch="armhf" version_conf="../version.sh" setup_conf="setup.conf"
	
	where version_conf and setup_conf point to the locations of the files.  
	'version.sh' is configured in the repository with the latest releases.
	'setup.conf' is customized to the person downloading (containing reference to locations of SSH keys and GITHUB OAUTH key).  
	    Only an example of this file will located in the riaps-integration repository.  User will need to edit this file for their setup. 
	    
3) Using 'fabfile_bbb.py' either do a full installation on the BBB (the first time) or an update when desired
	
	$ fab -f fabfile_bbb.py bbb_full_install   
	   
	            or
	            
	$ fab -f fabfile_bbb.py bbb_install_update  	
	
	Note:  Fabric must be installed on the VM (sudo pip install fabric).  This is a python2 script.


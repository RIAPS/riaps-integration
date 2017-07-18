# Setting up the BBB images

1. Download the latest BBB image from the RIAPS Wiki.

    https://riaps.isis.vanderbilt.edu/redmine/attachments/download/249/bbb_base_20170718.tar.gz
    
2. Copy the image to the BBB SD Card using a host machine and an SD Card reader.  A good open source tool for transferring the image to a SD Card is https://etcher.io/.

3. Put the SD Card into the BBB and boot it up.

4. Log into the "riaps" account on the BBB.

5. Add the RIAPS packages to the BBBs by using the following command (on the BBB).
```
        $ ./riaps_install_bbb.sh 2>&1 | tee install-bbb-riaps.log
```	

6. You can ssh into the BBBs using the following:

	```
	Username:  riaps
	Password:  riaps
	
	$ ssh riaps@xxx.xxx.xxx.xxx
	            where xxx.xxx.xxx.xxx is the IP address of the BBB
	      or
	$ ssh riaps@bbb-xxxx
	            where xxxx is the hostname seen when logging into the BBBs
	```
	
7. Secure communication between the Host Environment and the BBBs by following the "Securing Communication Between the VM and BBBs" instructions on https://github.com/RIAPS/riaps-integration/tree/master/riaps-x86runtime.  Once this process completes, the host environment will automatically login to the bones when using ssh utilizing your ssh keys.
  
# Update RIAPS Platform Packages on Existing BBBs

1. Download the RIAPS update script (https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install_bbb.sh) to the BBB.

2. Run the update script.

	```
	$ sudo apt-get update
	$ sudo apt-get update 'riaps-*' 2>&1 | tee install-riaps-update-bbb.log
	```

# Helpful Hints 

1. You can download the latest release to your VM and then 'scp' it over to the BBB using the following, substituting the 192.168.1.xxx with the IP address of your BBB.
    
	```
        $ scp riaps-bbbruntime.tar.gz ubuntu@192.168.1.xxx:
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
    $ sudo systemctl status riaps-<name>.service
    $ sudo systemctl start riaps-<name>.service
    $ sudo systemctl stop riaps-<name>.service
    $ sudo systemctl enable riaps-<name>.service
    $ sudo systemctl disable riaps-<name>.service
    ```
 NOTE: a fabfile will be provided in the near future to make things easier to turn on and off
   

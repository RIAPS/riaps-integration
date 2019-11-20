# Setting up the BBB images

1) Download the latest BBB image (riaps_bbb_4GB_v[date].tar.gz) from
   https://riaps.isis.vanderbilt.edu/downloads/. Choose the latest date folder.

2) Copy the image to the BBB SD Card using a host machine and an SD Card reader.  
   A good open source tool for transferring the image to a SD Card is https://etcher.io/.

3) Put the SD Card into the BBB and boot it up.  

>Note:  newer BBBs should be set to boot to the SD card automatically, when present.

4) Log into the "riaps" account on the BBB.

 You can ssh into the BBBs using the following:

    Username:  riaps
    Password:  riaps

```
ssh -i /home/riaps/.ssh/id_rsa.key riaps@XXX.XXX.XXX.XXX
```
>  where **xxx&#46;xxx&#46;xxx&#46;xxx** is the IP address of the BBB

5) Starting with v1.1.17, the BBB image does not have RIAPS pre-installed.  So,
   install the RIAPS platform using

```./riaps_install_bbb 2>&1 | tee install-riaps-bbb.log```

6) Optional Step:  If desired, secure communication between the Host Environment
   and the BBBs by following the [Securing Communication Between the VM and BBBs](../riaps-x86runtime/README.md#secure-comm)
   instructions.  Once this process completes, the host environment will automatically
   login to the beaglebones when using ssh by utilizing your ssh keys.  Note that
   password access to the BBBs will be disabled after running this process.  

> Note:  First time users should skip this step on first setup of their system.  
  The RIAPS example programs will work with the initial security configuration.

7) Reboot the BBBs

# Update RIAPS Platform Packages on Existing BBBs

1) Download the [RIAPS update script](riaps_install_bbb.sh) to the BBB.

2) Stop the riaps_deplo service by running the kill script.

```
sudo systemctl stop riaps-deplo.service
```

3) Run the update script.

```
./riaps_install_bbb.sh 2>&1 | tee install-riaps-update-bbb.log
```

> Note:  The user configuration files (riaps.conf and riaps-log.conf) are preserved
  when a new version of riaps-pycom is installed.  If you want to reset to the
  basic configuration, then delete the /etc/riaps.conf and /etc/riaps-log.conf and
  reinstall riaps-pycom.  Also, all files are linked such that pycom can still load
  these files from /usr/local/riaps/etc/, so no change in code is required.

> Note for v1.1.16 users:  The platform move from RIAPS v1.1.15 or RIAPS v1.1.16 are
  breaking builds,  in step 3 use the ```riaps_update_bbb_v1_1_16.sh``` script to
  make sure deprecated packages and old configuration files are removed.

# Helpful Hints

1. If you try 'scp' or 'ssh' and receive the following message, remove the '~/.ssh/known_host'
   file and try again.

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
...
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

1) **riaps-deplo.service** - will start the RIAPS deployment application.  This
   service starts the RIAPS discovery service.  When enabled, this service is setup
   to restart if it fails.

   - this service is currently disabled on the VM by default
   - this service is currently enabled and started on the BBB by default

2) **riaps-rm-cgroups.service** - this service runs when the BBB is booted to
   configure the RIAPS cgroups tools

3) **riaps-rm-quota.service** - this service runs when the BBB is booted to
   configure the quota tools

To see the status of a service or control its state, use the following commands
manually on a command line, where name is the service name (like deplo).  Starting
a service runs the actions immediately.  Enabling the service will allow the service
to start when booting up.  Disabling a service will completely turn the service
off (even when rebooted).  Stopping a service will just stop the service for the
current boot of the BBB, it will be back on after the next reboot, unless it is disabled.

```
sudo systemctl status riaps-<name>.service
sudo systemctl start riaps-<name>.service
sudo systemctl stop riaps-<name>.service
sudo systemctl enable riaps-<name>.service
sudo systemctl disable riaps-<name>.service
```

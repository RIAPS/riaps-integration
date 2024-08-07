# Setting up the Remote RIAPS Node Images

1) Download the latest RIAPS Node image (i.e. for bbb: riaps_bbb_4GB_[version].zip) from
   https://riaps.isis.vanderbilt.edu/rdownloads.html. Choose the latest released image.

   Available architectures are:
   - armhf for Beaglebone Black boards
   - arm64 for both Raspberry Pi 4 boards and TI AM64B starter kit

2) Copy the image to a SD Card using a host machine and an SD Card reader.  
   A good open source tool for transferring the image to a SD Card is https://etcher.io/.

3) Put the SD Card into the RIAPS node machine and boot it up.  

>Note:  newer BBBs should be set to boot to the SD card automatically, when present.

4) The downloaded image is not configured with security keys, so the connection needs to be established between the VM and the remote nodes. 
   Use the [Connect the VM to the Remote Nodes](../riaps-x86runtime/README.md#connect-remotes) instructions to establish these connections. 
   
5) Downloaded nodes can be logged in using `ssh` until the communication is secured. You can ssh into the nodes using the following:

    Username:  riaps
    Password:  riaps

   ```
   ssh riaps@XXX.XXX.XXX.XXX
   ```
   >  where **xxx&#46;xxx&#46;xxx&#46;xxx** is the IP address of the node

6) The RIAPS Node images do not have RIAPS pre-installed.  Use the [Installing RIAPS Packages on the Remote RIAPS Nodes](../riaps-x86runtime/README.md#install-riaps-nodes) instructions.

7) Reboot the RIAPS nodes

# Update RIAPS Platform Packages on Existing RIAPS Nodes Manually

See step 6 in the previous section to update all remote nodes at once using the appropriate `riaps_fab` command.  These instructions are for users that want to update the remote nodes manually.

1) Download the [RIAPS update script](riaps_install_node.sh) to the remote RIAPS node. 

2) Stop the riaps_deplo service by running the kill script.

   ```
   sudo systemctl stop riaps-deplo.service
   ```

3) Run the update script.

   ```
   ./riaps_install_node.sh 2>&1 | tee install-riaps-node.log
   ```

> Note: The user configuration files (riaps.conf and riaps-log.conf) are preserved when a new version of riaps-pycom is installed.  If you want to reset to the basic configuration, then delete the /etc/riaps.conf and /etc/riaps-log.conf and reinstall riaps-pycom.  Or remove and purge the package with `sudo apt-get purge riaps-pycom`.
  

# Helpful Hints

1. If you try `scp` or `ssh` and receive the following message, remove the `~/.ssh/known_host`
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

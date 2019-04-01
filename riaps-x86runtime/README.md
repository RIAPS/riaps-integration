# RIAPS Host Environment Setup Instructions

## Importing the RIAPS Virtual Machine

A virtual machine running Xubuntu 18.04 is preloaded with a tested RIAPS host environment. It is setup with the RIAPS specific tools, eclipse development with example applications for experimentation, and multi-architecture cross compilation capability (amd64 and armhf).

1) Download the exported RIAPS virtual machine appliance file (riaps_devbox_v[date].tar.gz) and untar it.  Choose the latest date folder under https://riaps.isis.vanderbilt.edu/downloads/.  This is an Virtual Machine Disk (.vmdk) that can be attached to VMs in both VirtualBox and VMware tools.

  This virtual machine (riaps-devbox.vmdk) was configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 2.0 (EHCI) Controller

> ***Note: Guest Additions tools were not included and will need to be setup by the user.***

2) Setup a new Linux VM with Ubuntu (64-bit).  Either use the same setup as indicated above, or adjust to match your system's capabilities.  Minimum suggested base memory size is 6144 MB.

3) Once the VM is created, open the settings add the downloaded Virtual Machine Disk (.vmdk) as a "Storage" device (under SATA).  Delete the drive (SATA) created when setting up the new VM.  

4) Setup the network settings to have Adapter 1 = "NAT" and Adapter 2 = "Bridged Adapter" pointing to the local network where the RIAPS nodes are attached.

5) Start up the VM and login as **RIAPS App Developer**.  The initial password is **riaps**.  You will be asked to change the password on this first login.

6) For VirtualBox tools, install the Guest Additions CD image and install them on the VM.  This will allow the use of device drivers (such as USB ports and network adapters), shared clipboard, drag'n'drop, and shared folders.

  * Under Devices Menu, select **Insert Guest Additions CD image...**
  * Open the file manager to determine where the image was mounted.
  * Open an terminal window and navigate to the image directory.
  * Run the installation tool
     ```
     sudo ./autorun.sh
     ```
  * Eject the Guest Additions CD when complete.
  * Shutdown the VM to configure the Guest Addition options
  * Select the VM and open the settings.  
    - Under General, there are Shared Clipboard and Drag'n'Drop options that are useful.
    - Under Shared Folders, select a folder to share on the host and make it "Auto-mount" and "Make Permanent".  You will be able to reach this folder from within the VM by ```sudo cp afilename /media/sf_sharedFolder```
  * Restart the VM

## <a name="config-network">Configuring Environment for Local Network Setup</a>

Setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

1) Determine the desired ethernet interface

```
ifconfig
```   

2) Edit the riaps configuration to enable that interface

```
sudo nano /usr/local/riaps/etc/riaps.conf
```   

3) Make sure the NIC name and match the desired ethernet interface name from 'ifconfig'

```
# NIC name
# Typical VM interface
#nic_name = eth0
nic_name = enp0s8
```

> ***Note:  This is necessary on the first installation.  If you want to reset to the basic configuration, then delete the /etc/riaps.conf and /etc/riaps-log.conf and reinstall riaps-pycom.  Also, all files are linked such that pycom can still load these files from /usr/local/riaps/etc/, so no change in code is required.***

4)  After changing the NIC name, restart the rpyc running in the background.

```
sudo systemctl restart riaps-rpyc-registry.service
```

## <a name="secure-comm">Securing Communication Between the VM and BBBs</a>

The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.

>**IMPORTANT:  Before running this script make sure all the remote RIAPS hosts are reachable by using a system check command: ```riaps_fab sys.check```.  If you are working only on the VM, do not use this script.**

Run this scripts using ```./secure_keys```, optionally add a ```-H <comma separated list of hostnames>``` or ```-f <absolute path to hostfile>```.  See documentation on using the [fabfile](https://github.com/RIAPS/riaps-pycom/tree/master/src/riaps/fabfile) to learn more about hostname definitions.

>Suggestion:  Save your SSH keys in a secure spot for use in the future (if needed), preferably in a location outside the virtual machine.

To add additional RIAPS Hosts to a system that has already been rekeyed, use ```-A <comma separated list of hostnames>``` when calling  ```secure_keys```.  This will set the new hosts up with the same keys and certificates as the current development system setup.

To remove RIAPS Hosts from a system, it is suggested that you remove the desired hostname from the riaps-hosts.conf file and rekey the system again.  That way the removed host will no longer have a valid set of keys and certificates for the system.  

>Note:  If a RIAPS host is moved to a new system that does not have access to the host's current ssh key pair or certificates, then it is best to reflash the host image with the released download image and either rekey the new system (if it is a fresh download) or add the host to the new system using the ```-A``` option.  

# RIAPS Platform Update Process

If you want to only update the RIAPS platform, run the update script

```
./riaps_install_amd64.sh 2>&1 | tee install-riaps-update-vm.log
```

> Note:  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

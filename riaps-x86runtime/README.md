# RIAPS Host Environment Setup Instructions

## Importing the RIAPS Virtual Machine

A virtual machine running Xubuntu 18.04 is preloaded with a tested RIAPS host environment. It is setup with the RIAPS specific tools, eclipse development with example applications for experimentation, and multi-architecture cross compilation capability (amd64 and armhf).

1) Download the exported RIAPS virtual machine appliance file (riaps_devbox_v<date>.tar.gz) and untar it.  Choose the latest date folder under https://riaps.isis.vanderbilt.edu/downloads/.  This is an Open Virtualization Format 2.0 (.ova) file that can be imported into both VirtualBox and VMware tools.

  This virtual machine (riaps_devbox.ova) was configured with the following settings:
  - Disk Size:  10 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 3.0 (xHCI) Controller  


> ***Note: Guest Additions tools were not included and will need to be setup by the import user.***

2) Import the appliance (riaps_devbox.ova) into a virtual machine toolset.

3) Login as **RIAPS App Developer**.  The initial password is **riaps**.  You will be asked to change the password on this first login.

4) For VirtualBox tools, install the Guest Additions CD image and install them on the VM.  This will allow the use of device drivers (such as USB ports and network adapters), shared clipboard, drag'n'drop, and shared folders.

  * Under Devices Menu, select **Insert Guest Additions CD image...**
  * Open the file manager to determine where the image was mounted.
  * Open an terminal window and navigate to the image directory.
  * Run the installation tool
     ```
     sudo ./autorun.sh
     ```
  * Eject the Guest Additions CD when complete.
  * Shutdown the VM to configure the Guest Addition options
  * Select the VM and open the settings.  Under General, there are Shared Clipboard and Drag'n'Drop options that are useful.
  * Restart the VM

## <a name="config-network">Configuring Environment for Local Network Setup</a>

Setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

> ***Note:  Each time the RIAPS platform is updated (in particular, the riaps-pycom package), this configuration setup will need to be repeated.***

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

## <a name="secure-comm">Securing Communication Between the VM and BBBs</a>

The ssh keys on the preloaded virtual machine are **NOT SECURE**.  So generate new keys for this installation using ```ssh-keygen```.  These keys can then be shared with RIAPS nodes (or Beaglebone Black devices) to secure communication between the devices.  Place the keys in ```~/.ssh```.

The ```secure_key.sh``` on the VM can be used to secure the communication between the VM and the BBB with the new generated ssh keys (id_rsa.key/id_rsa.pub below).  Where **xxx&#46;xxx&#46;xxx&#46;xxx** is the IP address of the BBB on your network.  Make sure you are logged in as **riaps** user.  This will need to be repeated for all BBBs (or use a fabric script to assist).

```
./secure_keys.sh bbb_initial_keys/bbb_initial.key ~/.ssh/id_rsa.key ~/.ssh/id_rsa.pub xxx.xxx.xxx.xxx
```

> Suggestion:  Save your SSH keys in a secure spot for use in the future (if needed), preferably in a location outside the virtual machine.

# RIAPS Platform Update Process

If you want to only update the RIAPS platform, run the update script

```
./riaps_install_amd64.sh 2>&1 | tee install-riaps-update-vm.log
```

> ***Remember to [reconfigure the network setting](#config-network) in RIAPS after installation.***

> Note:  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

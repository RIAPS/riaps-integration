# RIAPS Host Environment Setup Instructions

## Importing the RIAPS Virtual Machine

A virtual machine running Xubuntu 20.04 is preloaded with a tested RIAPS host environment. It is setup with the RIAPS specific tools, eclipse development with example applications for experimentation, and multi-architecture cross compilation capability (amd64, armhf and aarch64).

1) Download the latest version of Oracle VM VirtualBox from https://www.virtualbox.org/
2) Visit the RIAPS Downloads page at https://riaps.isis.vanderbilt.edu/rdownloads.html, download the Development Host VM Image and `unxz` it with a tool like 7-zip. This is a Virtual Disk Image (.vdi), the virtual hard drive of your virtual machine. We recommend moving from your Downloads folder to a safer location.
3) Open VirtualBox and click the 'New' button to begin creating a virtual machine.
  - Under "Name and Operating System", name your new VM, select "Linux" from Type and select "Ubuntu 20.04 LTS" from Version
  - Under "Hardware", give your VM at least 8192 MB of memory and 4 Processors
  - Under "Hard Disk", select "Use an Existing Virtual Hard Disk File". Click the folder + green arrow Icon next to the drop-down to open the Hard Disk Selector. Click the "Add" icon, and navigate to your decompressed VDI file. This should add your VDI to the Hard Disk Selector window under "Not Attached". Click on it then click "Choose" at the bottom of the window. The VM should appear in the list at the left of the VirtualBox Manager window.

4) Select your VM in the VirtualBox Manager and click the Settings icon.
- Under "General" > "Advanced", select "Bidirectional" for both Shared Clipboard and Drag'n'Drop
- Under "Network" > "Adapter 2", select "Enable Network Adapter". Under the "Attached to:" list select "Bridged Adapter". In "Name" should appear a list of your host computer's network interfaces. **Select the interface with a local connection to any RIAPS nodes (e.g. BeagleBone Black)** ~~Select the interface that connects you to your local router, to which you have also connected any RIAPS nodes (e.g. BeagleBone Black). This will likely be an Ethernet interface. If you are using a USB to Ethernet adapter, have the adapter plugged in before starting this process.~~

5) Start up the VM and login as **RIAPS App Developer**.  The initial password is **riaps**.  You will be asked to change the password on this first login.  
    - Hint: After first entering the initial password (`riaps`), the login window might prompt "Changing Password for riaps". If so, enter `riaps` again. Only then will it offer the first "Enter New Password" prompt. Enter your new password, and it will ask you to confirm. Entering your new password at "Changing password for riaps" will result in an incorrect attempt.

6) Here we will install the VirtualBox Guest Additions.  This will allow the use of device drivers (such as USB ports and network adapters), shared clipboard, drag'n'drop, and shared folders.

  * At the top of your VM window, under Devices, select **Insert Guest Additions CD image...**
  * Double-click the CD added to the desktop to open the CD location.
  * In CD Location file window, right click anywhere and select "Open Terminal Here"
  * Run the installation tool
     ```
     sudo ./autorun.sh
     ```
  * Eject the Guest Additions CD when complete. (optional)
  * Restart the VM

## <a name="create-network">Create network between VM and RIAPS nodes</a>
RIAPS currently supports two different Local Area Network (LAN) configurations: VM sharing router with RIAPS nodes, and VM acting as router for RIAPS nodes. 

### VM sharing router with RIAPS nodes
In this configuration the VM is connected to an internet router and shares the router's internet connection with the RIAPS nodes. Connect the VM's bridged internet adapter to the router's client ethernet ports to put the VM in the same LAN as the RIAPS nodes.

### VM acting as router for RIAPS nodes
**Instructions for Windows host machines only**
In this configuration, the host machine is connected to the internet on some interface other than the bridged adapter. The host machine's internet connection can then be shared with RIAPS nodes that are connected directly to the VM using an unmanaged network switch. This is useful for situations where a router is not available, or no internet connection is available whatsoever.

1. In Windows on the host machine, open the "Network Connections" settings window. Find the interface your VM is bridged to, and the interface of your internet connection.
2. Right click on you internet connection's interface, select "Properties".
3. In that interface's "Properties" window, select the "Sharing" tab.
4. Click "Allow other network users to connect through this computer's Internet connection", and in the "Home networking connection" drop-down, select the interface of your VM's bridged adapter.

You can now connected a simple, unmanaged network switch to your VM's bridged adapter with an ethernet cable, and any RIAPS nodes to the other ports on the switch. Windows will assign IP addresses from the 192.168.137.0/24 range to your RIAPS nodes and VM.







## <a name="config-network">~~Configuring Environment for Local Network Setup~~ Maybe unnecessary?</a>

Setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

1) Determine the desired ethernet interface

```
ifconfig
```   

2) Edit the riaps configuration to enable that interface

```
sudo nano /etc/riaps/riaps.conf
```   

3) Make sure the NIC name and match the desired ethernet interface name from 'ifconfig'

```
# NIC name
# Typical VM interface
#nic_name = eth0
nic_name = enp0s8
```

> ***Note:  ~~This is necessary on the first installation.  If you want to reset to the basic configuration, then delete the /etc/riaps.conf and /etc/riaps-log.conf and reinstall riaps-pycom.  Also, all files are linked such that pycom can still load these files from /usr/local/riaps/etc/, so no change in code is required~~. This may be out of date?***

4)  After changing the NIC name, restart the rpyc running in the background.

```
sudo systemctl restart riaps-rpyc-registry.service
```

## <a name="secure-comm">Securing Communication Between the VM and Remote RIAPS Nodes</a>

The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.

>***IMPORTANT:  Before running this script make sure ALL the remote RIAPS hosts are reachable by using a system check command: ```riaps_fab sys.check```.  If you are working only on the VM, do not use this script.  Make sure the VM hostname is listed as the control in the /etc/riaps/riaps-hosts.conf file so that it can be excluded when updating the remote keys. The VM is automatically be updated with this `secure_keys` script. If a node is not available when running this script, you can use the `-A` option to add the remote node. ***

Run this scripts using ```./secure_keys```, optionally add a ```-H <comma separated list of hostnames>``` or ```-f <absolute path to hostfile>```.  See documentation on using the [fabfile](https://github.com/RIAPS/riaps-pycom/tree/master/src/riaps/fabfile) to learn more about hostname definitions.

>Suggestion:  Save your SSH keys in a secure spot for use in the future (if needed), preferably in a location outside the virtual machine.

To add additional RIAPS Hosts to a system that has already been rekeyed, use ```-A <comma separated list of hostnames>``` when calling  ```secure_keys```.  This will set the new hosts up with the same keys and certificates as the current development system setup.

To remove RIAPS Hosts from a system, it is suggested that you remove the desired hostname from the riaps-hosts.conf file and rekey the system again.  That way the removed host will no longer have a valid set of keys and certificates for the system.  

>Note:  If a RIAPS host is moved to a new system that does not have access to the host's current ssh key pair or certificates, then it is best to reflash the host image with the released download image and either rekey the new system (if it is a fresh download) or add the host to the new system using the ```-A``` option.  

# RIAPS Platform Update Process

If you want to only update the RIAPS platform, run the update script

```
./riaps_install_vm.sh 2>&1 | tee install-riaps-update-vm.log
```

> Note:  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

> Note for v1.1.16 users:  The platform move from RIAPS v1.1.15 or RIAPS v1.1.16 are
  breaking builds, it is best to create a new VM using the image on the downloads page.

> Note for v1.1.17 users: there is a 'riaps_update_vm_v1_1_18.sh' script to help
  with this update since there are additional third party packages utilized by the
  RIAPS updates.  Instructions on how to use this script is included in the comments at the beginning
  of the script.  This will uninstall the local .conf files (/etc/riaps/) and key files, so 1) reset the
  nic_name in /etc/riaps/riaps.conf, 2) update the /etc/riaps/riaps-hosts.conf file to point to desired
  remote nodes (riaps-xxxx, instead of bbb-xxxx) and 3) re-secure the newly update remote notes to the VM
  using the "Securing Communication between the VM and Remote RIAPS Nodes".

## Suggestions for Transferring Eclipse Workspaces to a new VM

There are several ways to transfer your project work between VM.  Perhaps the easiest is to keep your
code in a code repository (such as SVN or GIT) and then create a new workspace from the retrieval of
the code from the repository.

Another way would be to use Eclipse to export an archive file that can be moved to a transfer site
(such as Dropbox or any other file sharing tool).  And then import that file into a new VM eclipse
workspace.  Here are some tips for doing this:

1) In the old VM, choose 'File' --> 'Export' from the drop-down menus and select the
   'General - Archive Files' option.

2) Select all the files you want to include in the archive.  You can unselect compiled files or even
   use the 'Filter Types' tool to help with this.  Indicate the file name and location to place this
   archive ('To archive file:' box).

3) Copy the file to a transfer site (such as Dropbox) and then retrieve it on the new VM.

4) On the new VM, choose 'File' --> 'Import' from the drop-down menus and select the
   'General - Existing Projects into Workspace' option.

5) 'Select the archive file' option and find the transferred file.

6) This should have the workspace back in place in the new VM.

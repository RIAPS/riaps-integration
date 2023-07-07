# RIAPS Host Environment Setup Instructions

## Initial System Setup 

The first three steps are required to establish a host environment that can communicate with the system of remote nodes.  The fourth step is encouraged to create a setup that is secured to a specific RIAPS Virtual Machine with unique security keys.

### <a name="connect-remotes">1) Importing the RIAPS Virtual Machine</a>

A virtual machine running Xubuntu 20.04 is preloaded with a tested RIAPS host environment. It is setup with the RIAPS specific tools, eclipse development with example applications for experimentation, and multi-architecture cross compilation capability (amd64, armhf and aarch64).

1) Download the exported RIAPS virtual machine appliance file (riaps_devbox_[version].vdi.xz) and unxz it.  Choose the latest release Development Host VM image on https://riaps.isis.vanderbilt.edu/rdownloads.html.  This is an Virtual Machine Disk (.vdi) that can be attached to VMs in both VirtualBox and VMware tools.

  This virtual machine (riaps-devbox.vdi) was configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 2.0 (EHCI) Controller

> ***Note: Guest Additions tools were not included and will need to be setup by the user.***

2) Setup a new Linux VM with Ubuntu (64-bit).  Either use the same setup as indicated above, or adjust to match your system's capabilities.  Minimum suggested base memory size is 6144 MB.

3) Once the VM is created, open the settings add the downloaded Virtual Machine Disk (.vdi) as a "Storage" device (under SATA).  Delete the drive (SATA) created when setting up the new VM.  

4) Setup the network settings to have Adapter 1 = "NAT" and Adapter 2 = "Bridged Adapter" pointing to the local network where the RIAPS nodes are attached.

5) Start up the VM and login as **RIAPS App Developer**.  The initial password is **riaps**.  You will be asked to change the password on this first login.  
    - Hint: After first entering the initial password (`riaps`), the login window might prompt "Change Password". Enter `riaps` again to confirm this and see the first "Enter New Password" prompt. Enter your new password, and it will ask you to confirm. Entering your new password at "Change Password" will result in an incorrect attempt.

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

### <a name="config-network">2) Configuring Environment for Local Network Setup</a>

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

> ***Note:  This is necessary on the first installation.  If you want to reset to the basic configuration, then delete the /etc/riaps.conf and /etc/riaps-log.conf and reinstall riaps-pycom.  Also, all files are linked such that pycom can still load these files from /usr/local/riaps/etc/, so no change in code is required.***

4)  After changing the NIC name, restart the rpyc running in the background.

```
sudo systemctl restart riaps-rpyc-registry.service
```

### <a name="connect-remotes">3) Connect the VM to the Remote Nodes</a>

To communicate with the remote nodes using tools like `riaps_fab`, the VM must be able to automatically log into each node using a ssh security key.  The remote nodes are not configured with security keys, so the connection needs to be established between the VM and the remote nodes.

The remote nodes to connect can be identified in two different ways: 
1) using the RIAPS host definition file (/etc/riaps/riaps-hosts.conf) or
2) provide the list of nodes when running the connection script using the `-H <comma separated list of hostnames>`.  This option is good when adding new nodes to the setup.

> Note: It is helpful to setup the `/etc/riaps/riaps-hosts.conf` file since it is utilized in the next step when securing the system communications.

The available remotes nodes and the associated hostnames can be determine by looking at the router interface to see the client names or `ssh` into each node to find the prompt name which indicates the <username>@<hostname>.  The hostnames used for should include the addition of `.local` or can be an IP Address of the nodes. See documentation on using the [fabfile](https://github.com/RIAPS/riaps-pycom/tree/master/src/riaps/fabfile) to learn more about hostname definitions and the `/etc/riaps/riaps-hosts.conf` file.

The connection script (`connect_remote_nodes.sh`) will connect to each remote node specified to update the security keys to match the VM setup. For each node, the user will be requested to add this host to the known hosts file by saying "Yes" and type in the node password (default is `riaps`) to complete the transfer of the VM key. An example successful exchange is below.  If this command is repeated as connection issues are addressed, the hostname will already be in the known host file, therefore the request to add a host question will not appear. If previous runs succeeded in connecting with some of the nodes, then those nodes will no longer need a password to connect and will transfer the VM key automatically.

```
$ ./connect_remote_nodes.sh -H riaps-f452.local,riaps-fd98.local
Remote Nodes Provided
Controller hostname: riaps-VirtualBox.local
Controller IPs: <IP addresses> 
>>>>> Setting up remote node: riaps-f452.local (you must enter a password for each remote node) <<<<<
The authenticity of host 'riaps-f452.local (<IP Address>)' can't be established.
ECDSA key fingerprint is SHA256:<hash>.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'riaps-f452.local,<IP Address>' (ECDSA) to the list of known hosts.
Ubuntu 20.04.6 LTS

rcn-ee.net Ubuntu 20.04.5 Console Image 2023-06-30
Support: http://elinux.org/BeagleBoardUbuntu
default username:password is [riaps:riaps]

riaps@riaps-f452.local's password: 
id_rsa.pub                                                                 100%  576   128.7KB/s   00:00 
>>>>> Connection between riaps-f452.local and controller has succeeded <<<<<   
>>>>> Setting up remote node: riaps-fd98.local (you must enter a password for each remote node) <<<<<
The authenticity of host 'riaps-fd98.local (<IP Address>)' can't be established.
ECDSA key fingerprint is SHA256:<hash>.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'riaps-fd98.local,<IP Address>' (ECDSA) to the list of known hosts.
Ubuntu 20.04.6 LTS

rcn-ee.net Ubuntu 20.04.5 Console Image 2023-06-30
Support: http://elinux.org/BeagleBoardUbuntu
default username:password is [riaps:riaps]

riaps@riaps-fd98.local's password: 
id_rsa.pub                                                                 100%  576   142.2KB/s   00:00    
>>>>> Connection between riaps-fd98.local and controller has succeeded <<<<<   
```

Once all the keys are setup successfully, a system check will be performed to make sure communication exists between all the remote hosts.  A successful output is:

```
=== fab -f /usr/local/lib/python3.8/dist-packages/riaps/fabfile/ sys.check     
[riaps-f452.local] Executing task 'sys.check'
[riaps-fd98.local] Executing task 'sys.check'
[riaps-VirtualBox.local] Executing task 'sys.check'
[riaps-VirtualBox.local] hostname && uname -a
riaps-VirtualBox
Linux riaps-VirtualBox 5.15.0-76-generic #83~20.04.1-Ubuntu SMP Wed Jun 21 20:23:31 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
[riaps-f452.local] hostname && uname -a
riaps-f452
Linux riaps-f452 5.10.168-ti-r63 #1focal SMP PREEMPT Wed Jun 28 03:27:34 UTC 2023 armv7l armv7l armv7l GNU/Linux
[riaps-fd98.local] hostname && uname -a
riaps-fd98
Linux riaps-fd98 5.10.168-ti-r63 #1focal SMP PREEMPT Wed Jun 28 03:27:34 UTC 2023 armv7l armv7l armv7l GNU/Linux

Done.
>>>>> If a response exists from all remote nodes, then remote node are now successfully communicating <<<<<

```

### <a name="install-riaps-nodes">4) Installing RIAPS Packages on the Remote RIAPS Nodes</a>

The downloaded images for the remote nodes do not include the RIAPS packages.  Once the VM to node communication is in place, `riaps_fab` can be used to install all the RIAPS packages.  There are two methods for installing the packages: using apt-get (to get the latest releases) or directly installing the .deb packages (used during development of the RIAPS platform).

To install the latest release, use ```riaps_fab riaps.update```.  This will pull the release information from the internet, so be sure all remote nodes have network access.

If the remote nodes do not have internet access or a development package (not yet released) is desired, the deb packages need to be gathered on the development VM before trying to installation. To retrieve the packages, pull the appropriate architecture and latest version from
 https://github.com/RIAPS/riaps-pycom/releases and https://github.com/RIAPS/riaps-timesync/releases. From the folder with the desired deb packages, run ```riaps_fab riaps.install```.  This command will utilize the configured `/etc/riaps/riaps-hosts.conf` file to determine the remote nodes.

 Another option is to use `scp` to transfer the file to a remote node, login to the remote node and then install using ```sudo dpkg -i <package name>```.  
  

### <a name="secure-comm">5) Securing Communication Between the VM and Remote RIAPS Nodes</a>

The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.

>***IMPORTANT:  Before running this script make sure ALL the remote RIAPS hosts are reachable by using a system check command: ```riaps_fab sys.check```.  If you are working only on the VM, do not use this script.  Make sure the VM hostname is listed as the control in the /etc/riaps/riaps-hosts.conf file so that it can be excluded when updating the remote keys. The VM is automatically updated with this `secure_keys` script. If a node is not available when running this script, you can use the `-A` option to add the remote node. ***

Run this scripts using ```./secure_keys```, optionally add a ```-H <comma separated list of hostnames>``` or ```-f <absolute path to hostfile>```.  See documentation on using the [fabfile](https://github.com/RIAPS/riaps-pycom/tree/master/src/riaps/fabfile) to learn more about hostname definitions.

>Suggestion:  Save your SSH keys in a secure spot for use in the future (if needed), preferably in a location outside the virtual machine.

To add additional RIAPS Hosts to a system that has already been rekeyed, use ```-A <comma separated list of hostnames>``` when calling  ```secure_keys```.  This will set the new hosts up with the same keys and certificates as the current development system setup.

To remove RIAPS Hosts from a system, it is suggested that you remove the desired hostname from the riaps-hosts.conf file and rekey the system again.  That way the removed host will no longer have a valid set of keys and certificates for the system.  

>Note:  If a RIAPS host is moved to a new system that does not have access to the host's current ssh key pair or certificates, then it is best to reflash the host image with the released download image and either rekey the new system (if it is a fresh download) or add the host to the new system using the ```-A``` option.  

In addition to updating the security keys of the VM and remote nodes, this script will turn off password access to the remote nodes by default.  If you are using the system for application development and would like to maintain password access to each remote node, run the script as follows: ```./secure_keys -p``` 


## RIAPS Platform Update Process

If you want to only update the RIAPS platform, run the update script

```
./riaps_install_vm.sh 2>&1 | tee install-riaps-update-vm.log
```

> Note:  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

### Suggestions for Transferring Eclipse Workspaces to a new VM

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

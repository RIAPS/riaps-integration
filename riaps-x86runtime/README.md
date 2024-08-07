# RIAPS Host Environment Setup Instructions

## Initial System Setup 

The first three steps are required to establish a host environment that can communicate with the system of remote nodes.  The fourth step is encouraged to create a setup that is secured to a specific RIAPS Virtual Machine with unique security keys.

### <a name="import-vm">1) Importing the RIAPS Virtual Machine</a>

A virtual machine running Xubuntu 22.04 is preloaded with a tested RIAPS host environment. It is setup with the RIAPS specific tools, eclipse development with example applications for experimentation, and multi-architecture cross compilation capability (amd64, armhf and aarch64).

1) Download the exported RIAPS virtual machine appliance file (riaps_devbox_[version].vdi.xz) and unxz it.  Choose the latest release Development Host VM image on https://riaps.isis.vanderbilt.edu/rdownloads.html.  This is an Virtual Machine Disk (.vdi) that can be attached to VirtualBox VM tool.

  This virtual machine (riaps-devbox.vdi) was configured with the following settings:
  - Type: Linux
  - Version: Xubuntu (64-bit)
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Disk Size:  100 GB dynamically allocated
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 2.0 (EHCI) Controller

> ***Note: Guest Additions tools were not included and will need to be setup by the user.***

2) Setup a new Linux VM with Xubuntu (64-bit).  Either use the same setup as indicated above, or adjust to match your system's capabilities.  Minimum suggested base memory size is 6144 MB.

3) When setting up the Hard Drive, choose the "Use an Existing Virtual Hard Disk File" option.  Add the downloaded .vdi file. 

4) Setup the network settings to have Adapter 1 = "NAT" and Adapter 2 = "Bridged Adapter" pointing to the local network where the RIAPS nodes are attached.

5) Start up the VM and login as **RIAPS App Developer**.  The initial password is **riaps**.  You will be asked to change the password on this first login.  
    - Hint: After first entering the initial password (`riaps`), the login window might prompt "Change Password". Enter `riaps` again to confirm this and see the first "Enter New Password" prompt. Enter your new password, and it will ask you to confirm. Entering your new password at "Change Password" will result in an incorrect attempt.

6) For VirtualBox tools, install the Guest Additions CD image and install them on the VM.  This will allow the use of device drivers (such as USB ports and network adapters), shared clipboard, drag'n'drop, and shared folders.

  * At the top of your VM window, under Devices, select **Insert Guest Additions CD image...**
  * Double-click the CD added to the desktop to open the CD location.
  * In CD Location file window, right click anywhere and select "Open Terminal Here"
  * Run the installation tool
     ```
     sudo ./autorun.sh
     ```
  * Eject the Guest Additions CD when complete. (optional)
  * Restart the VM

### <a name="create-network"> 2) Create Network Between VM and RIAPS Nodes</a>
RIAPS currently supports two different Local Area Network (LAN) configurations: VM sharing router with RIAPS nodes, and VM acting as router for RIAPS nodes. 

#### A) VM sharing router with RIAPS nodes
In this configuration the VM is connected to an internet router and shares the router's internet connection with the RIAPS nodes. Connect the VM's bridged internet adapter to the router's client ethernet ports to put the VM in the same LAN as the RIAPS nodes.

#### B) VM acting as router for RIAPS nodes
**For Windows host machines only**  
In this configuration, the host machine is connected to the internet on some interface other than the bridged adapter. The host machine's internet connection can then be shared with RIAPS nodes that are connected directly to the VM using an unmanaged network switch. This is useful for situations where a router is not available.

1. In Windows on the host machine, search "View network connections" from the Start menu and open the suggested window. Locate the interface your VM is bridged to, and the interface of your internet connection.
2. Right click on your internet connection's interface, select "Properties".
3. In that interface's "Properties" window, select the "Sharing" tab.
4. Click "Allow other network users to connect through this computer's Internet connection", and in the "Home networking connection" drop-down, select the interface of your VM's bridged adapter.

You can now connected a simple, unmanaged network switch to your VM's bridged adapter with an ethernet cable, and any RIAPS nodes to the other ports on the switch. Windows will assign IP addresses from the 192.168.137.0/24 range to your RIAPS nodes and VM.

### <a name="connect-remotes">3) Connect the VM to the Remote Nodes</a>

To communicate with the remote nodes using tools like `riaps_fab`, the VM must be able to automatically log into each node using a ssh security key.  The remote nodes are not configured with security keys, so the connection needs to be established between the VM and the remote nodes.

The remote nodes to connect can be identified in two different ways: 
1) using the RIAPS host definition file (/etc/riaps/riaps-hosts.conf) or
2) add a node when running the connection script using the `-H <hostname>` flag for each node. 

> Note: It is helpful to setup the `/etc/riaps/riaps-hosts.conf` file since it is utilized in the next step when securing the system communications.

The available remotes nodes and the associated hostnames can be determined by looking at the router interface to see the client names or `ssh` into each node to find the prompt name which indicates the `<username>@<hostname>`.  The hostnames used should include an addition of `.local` (i.e. riaps-xxxx.local) or can be an IP Address of the nodes. See documentation on using the [fabfile](https://github.com/RIAPS/riaps-pycom/tree/master/src/riaps/fabfile) to learn more about hostname definitions and the `/etc/riaps/riaps-hosts.conf` file.

The connection script (`connect_remote_nodes`) will connect to each remote node specified and will update the remote node security keys to match the VM setup. An example successful exchange is below using the `/etc/riaps/riaps-hosts.conf` file to define the remote nodes.  

```
./connect_remote_nodes 
Nodes to connect: ['riaps-bcf6.local', 'riaps-22d9.local']
>>>>> Connection between riaps-bcf6.local and controller has succeeded <<<<<
>>>>> Connection between riaps-22d9.local and controller has succeeded <<<<<
=== riaps_fab sys.check
Linux riaps-22d9 5.10.168-ti-rt-r72 #1jammy SMP PREEMPT_RT Sat Sep 30 03:48:01 UTC 2023 armv7l armv7l armv7l GNU/Linux
Linux riaps-bcf6 5.10.168-ti-rt-r72 #1jammy SMP PREEMPT_RT Sat Sep 30 03:48:01 UTC 2023 armv7l armv7l armv7l GNU/Linux
>>>>> If a response exists from all remote nodes, then the remote nodes are now successfully communicating <<<<<
```

To use the `-H <hostname>` option, here is an example command.

```
$ ./connect_remote_nodes -H riaps-bcf6.local -H riaps-22d9.local
``````

Once all the keys are setup successfully, a system check will be performed to make sure communication exists between all the remote hosts and the `/etc/riaps/riaps-hosts.conf` file is updated with the listed nodes.  If all the connections are not successful, then the `riaps-hosts.conf` file is not updated, even with the successful connections. 

Here is an example of an unsuccessful connections, where the `riaps-0e8a.local` node is not available:
```
./connect_remote_nodes
Nodes to connect: ['riaps-f852.local', '192.168.1.109'] 
Nodes to connect: ['riaps-22d9.local', 'riaps-bcf6.local', 'riaps-0e8a.local']
>>>>> Connection between riaps-22d9.local and controller has succeeded <<<<<
>>>>> Connection between riaps-bcf6.local and controller has succeeded <<<<<
>>>>> Connection failed between riaps-0e8a.local and controller <<<<<
An error occurred: [Errno -2] Name or service not known
>>>>> Check /etc/riaps/riaps-hosts.conf file for correct hostnames (or IP addresses) <<<<<
>>>>> Also check nodes that failed connections are running and network connected <<<<<
>>>>> Remote node connection failed <<<<<
```

### <a name="install-riaps-nodes">4) Installing RIAPS Packages on the Remote RIAPS Nodes</a>

The downloaded images for the remote nodes do not include the RIAPS packages.  Once the VM can successfully communication with all the remote nodes, `riaps_fab` can be used to install all the RIAPS packages.  There are two methods for installing the packages: using apt-get (to get the latest releases) or directly installing the .deb packages (used during development of the RIAPS platform).

To install the latest apt package release, use ```riaps_fab riaps.update```.  This command pulls the release information from the internet, so be sure all remote nodes have network access.

If the remote nodes do not have internet access or a development package (not yet released) is desired, the deb packages need to be gathered on the development VM before trying to installation. To retrieve the packages, pull the appropriate architecture and latest version from
 https://github.com/RIAPS/riaps-pycom/releases and https://github.com/RIAPS/riaps-timesync/releases. From the folder with the desired deb packages (typically `Downloads` folder), run ```riaps_fab riaps.install```.  This command will utilize the configured `/etc/riaps/riaps-hosts.conf` file to determine the remote nodes.

 Another option for advanced users is to use `scp` to transfer the file(s) to a remote node, login to the remote node and then install using ```sudo dpkg -i <package name>```.  
  
> Note: Depending on the number of remote nodes, the installation could take several minutes.  The script will indicate "Done" when the `riaps_fab` script has completed.  A `logs` folder will contain the results of the installation for each remote node and each package installed.  These can be referenced to debug any issues during the installation process.

### <a name="secure-comm">5) Securing Communication Between the VM and Remote RIAPS Nodes</a>

The ssh keys preloaded on the virtual machine are public, and therefore **NOT SECURE**.  To generate a new set of keys and certificates and write them to your nodes, use the```secure_keys``` script found in the RIAPS home directory.

> ***IMPORTANT:  Before running this script make sure ALL the remote RIAPS hosts are reachable by using a system check command: ```riaps_fab sys.check```.  If you are not working with remote nodes, and only a VM node, you can skip using `secure_keys`.  ***

```./secure_keys``` has two commands: `reset` and `add`.

`reset` is used to generate new SSH keys on the VM, then use them to secure your RIAPS nodes. By default, `secure_keys` reads your hostfile (/etc/riaps/riaps-hosts.conf) and secures the nodes listed there. If you are securing a nodes that have been secured previously, you can pass a path to the prior SSH private key with the `-i` flag.

>Suggestion:  Save your SSH keys in a secure spot for use in the future (if needed), preferably in a location outside the virtual machine.

`add` only secures new RIAPS nodes with your existing SSH keys. You can pass a hostnames of nodes to add with `-H <hostname>` for each one. This will set the new remote hosts up with the same keys and certificates as the current development system setup.

By default, `secure_keys` will remove password-based access to your remote nodes. This can be overridden by passing `-p`.

To remove RIAPS Hosts from a system, it is suggested that you remove the desired hostname from the riaps-hosts.conf file and rekey the system again. That way the removed host will no longer have a valid set of keys and certificates for the system. 

>Note:  If a RIAPS host is moved to a new system that does not have access to the host's current ssh key pair or certificates, then it is best to reflash the host image with the released download image and either rekey the new system (if it is a fresh download) or add the host to the new system using the ```add -H <hostname>``` option.  

## RIAPS Platform Update Process

If you want to only update the RIAPS Development VM with the latest released packages, run the update script

```
./riaps_install_vm.sh 2>&1 | tee install-riaps-update-vm.log
```

> Note:  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

### Suggestions for Transferring Eclipse Workspaces to a new VM

There are several ways to transfer your project work between VM.  Perhaps the easiest is to keep your
code in a code repository (such as GIT) and then create a new workspace from the retrieval of
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

## VirtualBox Host VM Setup Debug Tips

### Error While Adding Downloaded .vdi File as Disk

If a VirtualBox Error of `Failed to open the disk image file <disk location>` occurs and indicates in the details that it "cannot register the hard disk <disk location>(<UUID>) because a hard disk <another disk location> with (<UUID>) already exists", the UUID for the new disk needs to be reset.  This can be done by running the following command in a powershell.

```
C:\Program Files\Oracle\VirtualBox> ./VBoxManage.exe internalcommands sethduuid "<disk location/name>.vdi"
```

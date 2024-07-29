# To Build a RIAPS Virtual Machine Environment from Scratch

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
```
http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/22.04/release/
version 22.04.4 was used for the download image

Kernel:  6.5.0-44-generic 
```

2) Create a virtual machines configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Hard Disk File Type:  VDI (Virtual Machine Disk)
  - Hard Disk File Type:  VDI (Virtual Machine Disk)
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet); this step
  - USB Ports:  USB 1.1 (OHCI) Controller 
  - Check "Skip Unattended Installation", otherwise user will not be configured as sudoer when complete 

> ***Note: Guest Additions tools should not be included to allow the exported appliance to be compatible with both VirtualBox and VMware tools.  The importing user will be instructed to setup this feature.***

> ***Note: Must manually setup the second adapter setting.  This is important for `nic_name` configuration after RIAPS packages are installed.***

> Note: Using VirtualBox v7.0

3) Setup the Setting --> Network to have `Adapter` to have `Bridged Adapter` and configure with connection used to reach the router connected to the remote RIAPS nodes.

4) On VirtualBox main window, select START and pick your MEDIA SOURCE. In your case, select the xubuntu-22.04.4-desktop-amd64.iso on your desktop.  Install Xubuntu.  After installation, hit return to reboot into the new installation.

5) Create a `riapsadmin` user with password of `riapsadmin` and set computer name to `riaps-VirtualBox`.
   
6) Add `riapsadmin` user to the sudoers list by creating a new file `/etc/sudoers.d/riapsadmin` with the following contents.  The file permissions should be `0440` and owned by `root:root`.
```
riapsadmin  ALL=(ALL) NOPASSWD: ALL
```

7) Configure Software & Updates to turn off automatic check for updates and new version notification. Install requested updates to packages.

8) Additions for the quota functionality utilized in RIAPS must be added manually to insure no corruption occurs to the file system.  Edit the /etc/fstab files and add the `usrquota,grpquota` to `/`, as shown here:

```
# / was on /dev/sda1 during installation
UUID=871b6f90-d211-4de9-a0cb-f6ecdfe7c51f /               ext4    errors=remount-ro,usrquota,grpquota 0       1
/swapfile                                 none            swap    sw              0       0
```

9) Cgroups is set to v2 by default in XUbuntu 22.04, move the boot to use v1.  

   a) Edit `/etc/default/grub` to add `GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"`
  
   b) Apply the grub change with ```sudo update-grub```
    
10)  Restart the VM to allow the above `fstab`  and `grub` changes to take effect.

11)  To setup the usrquota and grpquota files, run the following. Restart the VM login as riapsadmin.

```
sudo apt-get install quota -y
sudo quotacheck -ugm /
sudo quotaon -a
sudo quotaon -pa
```

The last line provides feedback that the quota is setup.

12) Install `git` and clone `https://github.com/RIAPS/riaps-integration.git`

13) Navigate to the riaps-integration/riaps-x86runtime directory and edit the `vm_creation.conf` file to reflect the setup desired.  This file allows configuration of Ubuntu version, the cross compile architectures (for RIAPS nodes), version number of RIAPS to install and ssh key pair.

    a) Indicate desired Ubuntu setup, example below

    ```
    LINUX_DISTRO="ubuntu"
    CURRENT_PACKAGE_REPO="jammy"
    LINUX_VERSION_INSTALL="22.04"
    ```

    b) Indicate VM Host information, example below

    ```
    # Available RIAPS Node Architecture Types for cross compiling

    HOST_ARCH="amd64"
    VM_TOOLCHAIN_LOC="/usr/local"
    ```

    c) Indicate cross compile architecture information, example below

    ```
    ARCHS_CROSS=("armhf" "arm64")
    CROSS_TOOLCHAIN_LOC=("arm-linux-gnueabihf" "aarch64-linux-gnu")
    ```

    d) Indicate desired RIAPS version

    ```
    RIAPS_VERSION="v2.0.0"
    ```

14) Run the bootstrap script and send information provided to an installation log file.

```
sudo ./bootstrap.sh 2>&1 | tee install-vm.log
```

> Note:  If keys do not exist (which they do not in a fresh download), they will be created as part of the script.  

> Note: This script takes about an hour to run. For some reason, the redis_install function does not always do the wget on the first run. If this happens, edit to bootstrap.sh file to comment out the function calls at the bottom of the file that have already run (keeping the set -e and `source_scripts` lines) and start with this function.

> Note:  Files used to setup the eclipse projects are located in a private repository now.  This step (add_eclipse_projects within bootstrap.sh) can be skipped.

15) If everything installed correctly, remove riaps-integration repository from /home/riapsadmin/. Keep in mind that you will lose the install logs when removing this information.

16) Shutdown and then log in as "RIAPS App Developer".  The password change will be requested, but this will be reset at the end so that the user will be asked on their first login.

17) Remove the riapsadmin user account (deluser command).

18) Install the RIAPS packages

```./riaps_install_vm.sh 2>&1 | tee install-riaps-vm.log```

  Note:  Remember to setup the correct `nic_name` in the /etc/riaps/riaps.etc file for the VM.  The default is setup for the BBB images.  See [Configuring Environment for Local Network Setup](https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/README.md#configuring-environment-for-local-network-setup).

19) Add preloaded eclipse and sample applications in the default workspace.

    a) Pull the latest preloaded eclipse from `https://riaps.isis.vanderbilt.edu/rdownloads.html`.  Look for the latest version release of `riaps_eclipse.tar.gz`.

    b) Untar into the `/home/riaps` directory.

    c) Create a desktop icon in `/home/riaps/Desktop/Eclipse.desktop`

    ```
    [Desktop Entry]
      Encoding=UTF-8
      Type=Application
      Name=Eclipse
      Name[en_US]=Eclipse
      Icon=/home/riaps/eclipse/icon.xpm
      Exec=/home/riaps/eclipse/eclipse -data /home/riaps/workspace
    ```

    d) Import riaps_projects using `General` --> `Existing Projects into Workspace`.

    e) Configure Python (using `Advanced Auto-Config`) to utilize Python 3.10.

    f) Import riaps_launch_file using `Run/Debug` --> `Launch Configurations` to get riaps_ctrl and riaps_deplo.  Set these launches to display in External Tools Favorite list.  Make sure the "Build before launch" is not checked.

    g) Under `Preferences`, make sure all `C/C++` --> `Code Analysis` tools are unchecked.

    > Note:  See riaps_eclipse_information.md to learn more about how the preloaded eclipse image is created.

20) Turn off Snapshotting for the `Redis` tools

    Edit /etc/redis/redis.conf file to uncomment the `save ""` lines

```
################################ SNAPSHOTTING  ################################

# Save the DB to disk.
#
# save <seconds> <changes>
#
# Redis will save the DB if both the given number of seconds and the given
# number of write operations against the DB occurred.
#
# Snapshotting can be completely disabled with a single empty string argument
# as in following example:
#
save ""
```

21) Turn off apt tool automatic updating
    a) Edit `/etc/apt/apt.conf.d/20auto-upgrades` to set `Unattended-Upgrade` to "0"
    b) Edit `/etc/apt/apt.conf.d/10periodic` to set `Unattended-Upgrade` to "0"

    The settings should be for both files:
    ```
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Download-Upgradeable-Packages "0";
    APT::Periodic::AutocleanInterval "0";
    APT::Periodic::Unattended-Upgrade "0";
    ```

22) Add example applications for use in Eclipse from riaps-tutorials (https://github.com/RIAPS/riaps-tutorials.git)

23) Add Node-Red start script icon to Desktop.  
    a) Download the Node-Red icon from https://nodered.org/about/resources/media/node-red-icon.png
    b) Place icon image in /home/riaps folder
    c) Create a file on the Desktop call `node-red.desktop`, code is as follows:
    ```
    #!/usr/bin/env xdg-open
    
    [Desktop Entry]
    Type=Application
    Terminal=true
    Encoding=UTF-8
    Version=1.1
    Name=Node-Red Start
    Exec=/home/riaps/node-red-start.sh
    Categories=Development;GUIDesigner
    Icon=/home/riaps/node-red-icon.png

    Comment=
    Path=
    StartupNotify=false
    GenericName=MQTT and Node-Red Startup Script
    ```

24) Install mininet, see mininet_install function in [vm_utils_install.sh](https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/install_scripts/vm_utils_install.sh).  Due to an issue with the mininet installation script, the cloning of openflow needs to change from `git://...` to `https://...`.

>***Note: The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.***


## Things to do when preparing to release a new VM

1) Reset the `/etc/riaps/riaps-hosts.conf` file to have an empty list of nodes since testing might have added nodes to the list.  Leave the control definition as "riaps-VirtualBox.local"

2) Reset the password to the default and cause reset of password on next login.

```
sudo passwd riaps
sudo chage -d 0 riaps
```

3) Clear history in shells (`history -c && history -w`) and browsers (Firefox and Chrome)

4) To shrink the disk
    1)  Make sure zerofree is installed (apt)
    2)  Reboot the VM and repeatedly press the `Esc` key while it boots to access the Grub menu  
    3)  Select `*Advanced options for Ubuntu` and press `Enter`
    4)  Select the `(recovery mode)` option for the kernel used (i.e. highest number near top of the list) and press Enter
    5)  Select `root` in the recovery menu to boot to a root shell prompt
    6)  Press `Enter` afterwards when `Press Enter for maintenance` appears on your screen to get a command line prompt
    7)  Use `df` to locate the "/" disk device (/dev/sda5)
    8)  Use the following command to run zerofree: `systemctl stop systemd-journald.socket && systemctl stop systemd-journald.service && systemctl stop systemd-journald-dev-log.socket && systemctl stop systemd-journald-audit.socket && sudo swapoff -a && mount -n -o remount,ro -t ext4 /dev/sda5 / && zerofree -v /dev/sda5`
    9)  When done, type `halt` and shutdown the machine
    10) From a terminal window on the host machine use VBoxManage to compress the .vdi image
        
        a)  `VBoxManage.exe list hdds`    (this is to find the disk location)
        
        b)  `VBoxManage.exe modifymedium "<disk location>" --compact`

5) Reset the UUID of the VM disk (.vdi) to make it unique for this release. From a windows powershell, run the VBoxManage.exe command below.

```
$ C:\Program Files\Oracle\VirtualBox> VBoxManage.exe internalcommands sethduuid "<location of vdi disk to release>"
UUID changed to: 4ec9c8af-6b39-44b9-a03f-c9b1c943cf8c
```
>Note: Once the disk UUID changes, Oracle VM Virtual Manager can not find the disk.  The .vdi disk must be removed from the VM instance (using settings under the Storage section), remove the old disk information from the `Virtual Media Manager` (found under `File` --> `Tools`) - make sure to keep the file, then add the disk again to the VM instance as a new SATA hard disk using the `Add` button.  

6) Compress the VM disk (.vdi) using xz, create a sha256sum txt file and post in the appropriate place.

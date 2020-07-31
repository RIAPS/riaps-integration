# To Build a RIAPS Virtual Machine Environment from Scratch

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
```
http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/18.04/release/xubuntu-18.04.3-desktop-amd64.iso

Kernel:  5.4.0-42-generic (after SW update)
```

2) Create a virtual machines configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Hard Disk File Type:  VMDK (Virtual Machine Disk)
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 2.0 (EHCI) Controller  

> ***Note: Guest Additions tools should not be included to allow the exported appliance to be compatible with both VirtualBox and VMware tools.  The importing user will be instructed to setup this feature.***

3) Setup the Setting --> Network to have 'Adapter' to have 'Bridged Adapter' and configure with connection used to reach the router connected to the remote RIAPS nodes.

4) On VirtualBox main window, select START and pick your MEDIA SOURCE. In your case, select the xubuntu-18.04.3-desktop-amd64.iso on your desktop.  Install Xubuntu.  After installation, hit return to reboot into the new installation.

5) Create a 'riapsadmin' user with password of 'riapsadmin' and set computer name to `riaps-VirtualBox`.

6) Configure Software & Updates to turn off automatic check for updates and new version notification. Install requested updates to packages.

7) Additions for the quota functionality utilized in RIAPS must be added manually to insure no corruption occurs to the file system.  Edit the /etc/fstab files and add the "usrquota,grpquota" to '/', as shown here:

```
# / was on /dev/sda1 during installation
UUID=871b6f90-d211-4de9-a0cb-f6ecdfe7c51f /               ext4    errors=remount-ro,usrquota,grpquota 0       1
/swapfile                                 none            swap    sw              0       0
```

8) Restart the VM to allow the above 'fstab' changes to take effect.


9) To setup the usrquota and grpquota files, run the following. Restart the VM login as riapsadmin.

```
sudo apt-get install quota -y
sudo quotacheck -ugm /
sudo quotaon -a
sudo quotaon -pa
```

The last line provides feedback that the quota is setup.

10) Install 'git' and clone https://github.com/RIAPS/riaps-integration.git

11) Navigate to the riaps-integration/riaps-x86runtime directory and edit the 'vm_creation.conf' file to reflect the setup desired.  This file allows configuration of Ubuntu version, the cross compile architectures (for RIAPS nodes), version number of RIAPS to install and ssh key pair.

12) Run the bootstrap script and send information provided to an installation log file.

```
sudo ./bootstrap.sh 2>&1 | tee install-vm.log
```

> Note:  If keys do not exist (which they do not in a fresh download), they will be created as part of the script.  

> Note: This script takes about an hour to run. For some reason, the redis_install function does not always do the wget on the first run. If this happens, edit to bootstrap.sh file to comment out the function calls at the bottom of the file that have already run (keeping the set -e and 'source_scripts' lines) and start with this function.

13) If everything installed correctly, remove riaps-integration repository from /home/riapsadmin/. Keep in mind that you will loss the install logs when removing this information.

14) Shutdown and then log in as "RIAPS App Developer".  The password change will be requested, but this will be reset at the end so that the user will be asked on their first login.

15) Remove the riapsadmin user account (deluser command).

16) Add preloaded eclipse and sample applications in the default workspace.

  a) Pull the latest preloaded eclipse from https://riaps.isis.vanderbilt.edu/downloads/.  Look for the latest version release of
     riaps_eclipse.tar.gz.

  b) Untar into the /home/riaps directory.

  c) Create a desktop icon in /home/riaps/Desktop/Eclipse.desktop

    ```
     [Desktop Entry]
       Encoding=UTF-8
       Type=Application
       Name=Eclipse
       Name[en_US]=Eclipse
       Icon=/home/riaps/eclipse/icon.xpm
       Exec=/home/riaps/eclipse/eclipse -data /home/riaps/workspace
     ```

  d) Import riaps_projects using "General" --> "Existing Projects into Workspace".

  e) Configure Python (using "Advanced Auto-Config") to utilize Python 3.6.

  f) Import riaps_launch_file using "Run/Debug" --> "Launch Configurations" to get riaps_ctrl and riaps_deplo.  Set these launches to display in External Tools Favorite list.  Make sure the "Build before launch" is not checked.

  g) Under "Preferences", make sure all "C/C++" --> "Code Analysis" tools are unchecked.

> Note:  See riaps_eclipse_information.md to learn more about how the preloaded eclipse image is created.

17) Reset the password to the default and cause reset of password on next login.

    ```
    sudo chage -d 0 riaps
    ```

18) Compress the VM disk (.vmdk) using xz, create a sha256sum txt file and post in the appropriate place.

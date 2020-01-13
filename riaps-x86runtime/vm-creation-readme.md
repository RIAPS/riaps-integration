# To Build a RIAPS Virtual Machine Environment from Scratch

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
```
http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/18.04/release/xubuntu-18.04.3-desktop-amd64.iso
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

3) On VirtualBox main window, select START and pick your MEDIA SOURCE. In your case, select the xubuntu-18.04.3-desktop-amd64.iso on your desktop.  Install Xubuntu.  After installation, hit return to reboot into the new installation.

4) Create a 'riapsadmin' user with password of 'riapsadmin'.

5) Configure Software & Updates to turn off automatic check for updates and new version notification.

6) Additions for the quota functionality utilized in RIAPS must be added manually to insure no corruption occurs to the file system.  Edit the /etc/fstab files and add the "usrquota,grpquota" to '/', as shown here:

```
# / was on /dev/sda1 during installation
UUID=871b6f90-d211-4de9-a0cb-f6ecdfe7c51f /               ext4    errors=remount-ro,usrquota,grpquota 0       1
/swapfile                                 none            swap    sw              0       0
```

7) Restart the VM to allow the above fstab changes to take effect.

8) To setup the usrquota and grpquota files, run the following.  
   The last line provides feedback that the quota is setup.
```
sudo quotacheck -ugm /
sudo quotaon -a
sudo quotaon -pa
```

9) Install 'git' and clone https://github.com/RIAPS/riaps-integration.git

10) Navigate to the riaps-integration/riaps-x86runtime directory and run the bootstrap script.

```
sudo ./bootstrap.sh public_key=~/.ssh/id_rsa.pub private_key=~/.ssh/id_rsa 2>&1 | tee install-vm.log
```

> Note:  If keys do not exist (which they do not in a fresh download), they will be created as part of the script.  

11) Remove riaps-integration repository from /home/riapsadmin/.

12) Shutdown and then log in as "RIAPS App Developer".  The password change will be requested, but this will be reset at the end so that the user will be asked on their first login.

13) Remove the riapsadmin user account.

14) Setup riaps user with nopasswd using adding a /etc/sudoer.d/riaps file.  Then "chmod 0440 /etc/sudoer.d/riaps".

    ```
    riaps  ALL=(ALL) NOPASSWD: ALL
    ```

15) Add preloaded eclipse and sample applications in the default workspace.

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

	d) Move riaps_projects to the /home/riaps folder.  The projects placed here are from https://github.com/RIAPS/riaps-apps to provide starting projects for new developers (DistributedEstimator, DistributedEstimatorGPIO and WeatherMonitor).  

	e) Move the riaps-launch-files to the /home/riaps folder.  The launch files are located in https://github.com/RIAPS/riaps-pycom/tree/master/bin (riaps_ctrl.launch and riaps_deplo.launch).

	f) Import riaps_projects using "General" --> "Existing Projects into Workspace".

	g) Configure Python (using "Advanced Auto-Config") to utilize Python 3.6.

	h) Import riaps_launch_file using "Run/Debug" --> "Launch Configurations" to get riaps_ctrl and riaps_deplo.  Set these launches to display in External Tools Favorite list.  Make sure the "Build before launch" is not checked.

	i) Under "Preferences", make sure all "C/C++" --> "Code Analysis" tools are unchecked.

	j) Plugins already installed are:  
	   - CDT Optional Features --> C/C++ CMake Build Support - Preview Developer Resources
	   - Git integration for Eclipse - Task focused interface
	   - From Eclipse Marketplace:  Eclipse Xtend, Xtext, JSON Editor, PyDev
	   - Install the RIAPS DSML tool from https://riaps.isis.vanderbilt.edu/dsml 

16) Create ~/.riaps/riapsversion.txt file with permissions of 600 for future use in know the version installed on the VM image

17) Reset the password to the default and cause reset of password on next login.

    ```
    sudo chage -d 0 riaps
    ```

18) Compress the VM disk (.vmdk) using xz, create a sha256sum txt file and post in the appropriate place.

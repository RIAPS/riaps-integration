# To Build a RIAPS Virtual Machine Environment from Scratch

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
```
http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/18.04/release/xubuntu-18.04.1-desktop-amd64.iso
```

2) Create a virtual machines configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 2.0 (EHCI) Controller  

> ***Note: Guest Additions tools should not be included to allow the exported appliance to be compatible with both VirtualBox and VMware tools.  The importing user will be instructed to setup this feature.***

3) Create a 'riapsadmin' user with password of 'riapsadmin'.

4) Install 'git' and clone https://github.com/RIAPS/riaps-integration.git

5) Additions for the quota functionality utilized in RIAPS must be added manually to insure no corruption occurs to the file system.  Edit the /etc/fstab files and add the "usrquota,grpquota" to '/', as shown here:

```
# / was on /dev/sda1 during installation
UUID=871b6f90-d211-4de9-a0cb-f6ecdfe7c51f /               ext4    errors=remount-ro,usrquota,grpquota 0       1
/swapfile                                 none            swap    sw              0       0
```

6) Restart the VM to allow the above fstab changes to take effect.

7) Navigate to the riaps-integration/riaps-x86runtime directory and run the bootstrap script.

```
sudo ./bootstrap.sh public_key=~/.ssh/id_rsa.pub private_key=~/.ssh/id_rsa 2>&1 | tee install-vm.log
```

> Note:  If keys do not exist (which they do not in a fresh download), they will be created as part of the script.  

9) Copy the riaps_install_amd64.sh script to /home/riaps/ for use by the user to update the RIAPS platform.  Set owner as riaps.

10) Clone https://github.com/RIAPS/riaps-pycom.git to get the fabfile information and copy this into /home/riaps/.  Set owner as riaps.

11) Remove riaps-integration and riaps-pycom repositories from /home/riapsadmin/.

12) Shutdown and then log in as "RIAPS App Developer".  The password change will be requested, but this will be reset at the end so that the user will be
asked on their first login.

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

	d) Move riaps_projects and riaps-launch-files to /home/riaps folder.

	e) Import riaps_projects using "General" --> "Existing Projects into Workspace".

	f) Configure Python (using "Advanced Auto-Config") to utilize Python 3.6.

	g) Import riaps_launch_file using "Run/Debug" --> "Launch Configurations" to get riaps_ctrl and riaps_deplo.  Set these launches to display in External Tools Favorite list.  Make sure the "Build before launch" is not checked.

  h) Under "Preferences", make sure all "C/C++" --> "Code Analysis" tools are unchecked.

16) Reset the password to the default and cause reset of password on next login.

    ```
    sudo chage -d 0 riaps
    ```

17) Tar the VM disk (.vmdk), create a sha256sum txt file and post in the appropriate place.

# To Build a RIAPS Virtual Machine Environment from Scratch

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
``` 
http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/18.04/release/xubuntu-18.04.1-desktop-amd64.iso
```

2) Create a virtual machines configured with the following settings:
  - Disk Size:  100 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  2
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

12) Add eclipse configured with p2f files (location TBD) and sample applications in the default workspace. (MM Work in progress)

13) Log out and set the intended login user to be "RIAPS App Developer", so that the application developer find the right account.

14) Remove the riapsadmin user account

15) Tar the VM disk (.vmdk), create a sha256sum txt file and post in the appropriate place.

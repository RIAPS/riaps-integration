# To Build a RIAPS Virtual Machine Environment

This is information on how the preloaded RIAPS virtual machine was created.   

1) Download the latest version of Xubuntu:
``` http://mirror.us.leaseweb.net/ubuntu-cdimage/xubuntu/releases/18.04/release/xubuntu-18.04.1-desktop-amd64.iso
```

2) Create a virtual machines configured with the following settings:
  - Disk Size:  10 GB dynamically allocated
  - Base Memory:  8192 MB
  - Processor(s):  4
  - Video Memory:  16 MB
  - Network:  Adapter 1 - NAT, Adapter 2 - Bridged Adapter (to local ethernet)
  - USB Ports:  USB 3.0 (xHCI) Controller  

> ***Note: Guest Additions tools should not be included to allow the exported appliance to be compatible with both VirtualBox and VMware tools.  The importing user will be instructed to setup this feature.***

3) Create a 'vagrant' user with password of 'vagrant'.

4) Clone https://github.com/RIAPS/riaps-integration.git

5) Navigate to the riaps-integration/riaps-x86runtime directory and run the bootstrap script.

```
sudo ./bootstrap.sh public_key=id_rsa.pub private_key=id_rsa.key 2>&1 | tee install-vm.log
```

> Note:  If keys do not exist (which they do not in a fresh download), they will be created as part of the script.

6) Additions for the quota functionality utilized in RIAPS must be added manually to insure no corruption occurs to the file system.  Edit the /etc/fstab files and add the "usrquota,grpquota" to '/', as shown here:

```
# / was on /dev/sda1 during installation
UUID=871b6f90-d211-4de9-a0cb-f6ecdfe7c51f /               ext4    errors=remount-ro,usrquota,grpquota 0       1
/swapfile                                 none            swap    sw              0       0
```

7) Copy the riaps_install_amd64.sh script to /home/riaps/ for use by the user to update the RIAPS platform.

8) Clone https://github.com/RIAPS/riaps-pycom.git to get the fabfile information and copy this into /home/riaps/.

9) Remove riaps-integration and riaps-pycom repositories from /home/vagrant/.

10) Log out and set the intended login user to be "RIAPS App Developer", so that the application developer find the right account.

11) Shutdown the virtual box and export the appliance to a Open Virtualization Format 2.0 (.ova) file.  Check the "Write Manifest file" box.

12) Add the Version number (date of the creation) and License agreement information (see License in repository) to the Appliance settings.

13) Tar the file, create a sha256sum txt file and post in the appropriate place.

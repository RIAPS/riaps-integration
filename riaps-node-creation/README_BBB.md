# Create RIAPS BBB Base Image (4GB)

These are instructions on how the BBB Base image was created.  

## Start with Ubuntu Pre-configured Image from Robert Nelson

This work should be done on a Linux machine or VM. We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1) Download a complete pre-configured image (Ubuntu 20.04.1) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1).  Below is an example of a version used previously, beware that the available versions are updated monthly and only 3 are kept in this location.  Choose the latest version available.

```
wget https://rcn-ee.com/rootfs/2020-04-09/elinux/ubuntu-18.04.4-console-armhf-2020-04-09.tar.xz
```

2) Unpack image and change into the directory (unxz file, then tar xf)

3) Locate the SD Card on the Linux machine, looking for the appropriate /dev/sdX (i.e. /dev/sdb)

```
sudo ./setup_sdcard.sh --probe-mmc
```

4) Install image on SD card, where /dev/sdX is the location of the SD Card

```
sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone
```

Resulting image information:

```
Username:  ubuntu
Password:  temppwd
Kernel:    v4.19.xx-ti-rxx
```

## Installation of RIAPS Base Configuration on Pre-configured BBB

1) With the SD Card installed in the BBB, log into the BBB using ssh with user account being 'ubuntu'

2) Download and compress the [riaps-node-creation folder](https://github.com/RIAPS/riaps-integration/tree/master/riaps-node-creation) and transfer it to the BBB.

3) On the BBB, unpack the creation files and move into the folder

```
tar -xzvf riaps-node-creation.tar.gz
cd riaps-node-creation
```

4) Create a swapfile on the BBB to allow larger packages to run (such as spdlog)

```
sudo fallocate -l 1G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo su
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
exit
```

5) Reboot the BBB and still sign in as 'ubuntu'

6) Move to 'root' user

```
sudo su
```

7) Move back into the riaps-node-creation folder and run the installation script. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
./base_bbb_bootstrap.sh 2>&1 | tee install-bbb.log
```

> Note: this step takes about 5 hours to run

> Note:  This script has been updated to match the changing platform setup, due to time constraints it has not been run from scratch and may contain some syntax errors.  The intended contents is represented and accounted for in the file.

8) Remove install files from /home/ubuntu

9) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script. Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

10) Optional:  Remove the swapfile.  If you want to compile large third party libraries on this platform later, leave the swapfile (it does cost file space).

```
sudo swapoff -v /swapfile
sed -i "/swapfile/c\ " /etc/fstab
sudo rm /swapfile
```

11) Reboot BBB and sign in as 'riaps' user

12) Remove the 'ubuntu' user

```
sudo su
userdel -r ubuntu
```

13) Change owner of /opt/scripts from 1000 to root

14) Optional: Add SPI capability (which can be used for CAN communication)

    Edit the `/boot/uEnv.txt` file to add the following (as appropriate to the SPI port desired):

```
    ###Additional custom capes  
    uboot_overlay_addr4=/lib/firmware/BB-SPIDEV0-00A0.dtbo  
```

15) Optional: Turn off unattended package updates by editing /etc/apt/apt.conf.d/20auto-upgrades and set the "Unattended-Upgrade" to "0".

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";
```

16) Optional: Add the RIAPS packages to the BBBs by using the following command (on the BBB).

```
./riaps_install_node.sh "armhf" 2>&1 | tee install-node-riaps.log
```

- Reboot BBB to start the RIAPS services

> Note: Release images do not include the RIAPS packages installed.

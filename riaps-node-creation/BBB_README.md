# Create RIAPS BBB Base Image (4GB)

These are instructions on how the BBB Base image was created.  

## Start with Ubuntu Pre-configured Image from Robert Nelson

This work should be done on a Linux machine or VM. We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1) Download a complete pre-configured image (Ubuntu 18.04.4) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1).  Below is an example of a version used previously, beware that the available versions are updated monthly and only 3 are kept in this location.  Choose the latest version available.

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

2) Download and compress the [bbb-creation-files folder](https://github.com/RIAPS/riaps-integration/tree/master/bbb-creation-files) and transfer it to the BBB.

3) On the BBB, unpack the creation files and move into the folder

```
tar -xzvf bbb-creation-files.tar.gz
cd bbb-creation-files
```

4) Create a swapfile on the BBB to allow larger packages to run (such as spdlog)

```
sudo fallocate -l 1G /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
```

5) Reboot the BBB and still sign in as 'ubuntu'

6) Move to 'root' user

```
sudo su
```

7) Run the installation script. Provide the name of the ssh key pair added in step 5, your key filename can be any name desired. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
./base_bbb_bootstrap.sh 2>&1 | tee install-bbb.log
```

> Note:  This script has been updated to match the changing platform setup, due to time constraints it has not been run from scratch and may contain some syntax errors.  The intended contents is represented and accounted for in the file.

8) Remove install files from /home/ubuntu

9) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install_bbb.sh) in /home/riaps/ to allow updating of the RIAPS platform by script

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

14) Add the RIAPS packages to the BBBs by using the following command (on the BBB).

```bash
./riaps_install_bbb.sh 2>&1 | tee install-bbb-riaps.log
```


### Usage of BBB Image

Users of this image will ssh using the following:

```
Username:  riaps
Password:  riaps
```

Updated Real-time enabled Kernel will be (once rebooted)

```
Kernel: v4.14.xx-ti-rt-rxx
```

## Expanding File System Partition On A microSD

An easy and straightforward way to resize the partition on the sd card from the command line. The best part is it can be done while booted from the sd card that needs to be resized.

The original instructions are here:
https://elinux.org/Beagleboard:Expanding_File_System_Partition_On_A_microSD

The specific inputs used were :

    1) sudo -s
    2) fdisk /dev/mmcblk0
    3) p
    4) d
    5) n
    6) < I pressed enter to use default>
    7) < I pressed enter to use default>
    8) 8192
    9) < I pressed enter to use default>
    10) p
    11) w
    12) reboot
    13) sudo resize2fs /dev/mmcblk0p1

Even though it says the partition is being deleted whatever was installed is left intact.


## Resizing the Image to 4 GB with gparted
Use gparted in a VM to move to a 4096 MiB partition for rootfs of the new SD card
1) Become root user

```
sudo su
```

2) Start ```gparted```
3) Unmount the device
4) Resize to 4096 MiB

## Saving Image

1) Determine the end sector of the 4GB partition (in VM)

```
sudo fdisk -u -l

Disk /dev/sdb: 3.7 GiB, 3980394496 bytes, 7774208 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc35d5b25

Device     Boot Start     End Sectors  Size Id Type
/dev/sdb1  *     8192 7774207 7766016  3.7G 83 Linux
```

2) Copy the card to host:

```  
sudo dd if=/dev/sdb of=riaps-bbb-base-4GB.img count=7774207  


7766016+0 records in
7766016+0 records out
3976200192 bytes (4.0 GB, 3.7 GiB) copied, 171.161 s, 23.2 MB/s
```

3) Use https://www.balena.io/etcher/ tool to copy from host to SD card

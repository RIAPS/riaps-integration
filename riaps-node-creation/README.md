# Create RIAPS Node Base Image (4GB)

RIAPS nodes are typically deployed on single board computer solutions.  This folder contains scripts and instructions for creating RIAPS images for the supported solutions.

* TI Beagleboard Black
  - [Platform Information](http://beagleboard.org/black)
  - [Instructions for building a BBB RIAPS Image](README_BBB.md)
  - Kernel: v5.10.xx-ti-rt-rxx
  - Ubuntu: 20.04.5 LTS

* Raspberry Pi 4
  - [Platform Information](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/)
  - [Instructions for building a Raspberry Pi RIAPS Image](README_RPI.md)
  - Kernel: 5.4.0-xxxx-raspi
  - Ubuntu: 20.04.5 LTS

>***Note: The ssh keys on the preloaded virtual machine are **NOT SECURE**.  The ```secure_key``` found in the RIAPS home directory will generate a new set of keys and certificates, then place them on both the VM and indicated remote RIAPS hosts.***

# Usage of Remote RIAPS Node Image

Users of this image will ssh using the following:

```
Username:  riaps
Password:  riaps
```

The device hostname will be "riaps-xxxx", where xxxx is the first four digits of the board MAC address (so it will be unique per device).


# Expanding File System Partition On A microSD

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


# Resizing the Image to 4 GB with gparted
Use gparted in a VM to move to a 4096 MiB partition for rootfs of the new SD card
1) Become root user

```
sudo su
```

2) Start ```gparted```
3) Unmount the device
4) Resize to 4096 MiB


# Saving Image

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

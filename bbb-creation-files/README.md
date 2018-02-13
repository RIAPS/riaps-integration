# Create RIAPS BBB Base Image (4GB) 

These are instructions on how the BBB Base image was created.  

## Start with Ubuntu Pre-configured Image from Robert Nelson

This work should be done on a Linux machine or VM. We are starting with a pre-configured BBB Ubuntu image and modifying it to add the RT Patch kernel and any other customizations needed for RIAPS.

1. Download a complete pre-configured image (Ubuntu 16.04) onto the BBB SD Card - http://elinux.org/BeagleBoardUbuntu (Instructions - start with Method 1)

```
$ wget https://rcn-ee.com/rootfs/2018-02-09/elinux/ubuntu-16.04.3-console-armhf-2018-02-09.tar.xz
```

Note:  If this file is not available, contact VU project members.

2. Unpack image and change into the directory (unxz file, then tar xf)

```
Username:  ubuntu
Password:  temppwd
Kernel:    v4.9.xx-ti-rxx (with real-time features)
```

3. Locate the SD Card on the Linux machine, looking for the appropriate /dev/sdX (i.e. /dev/sdb)

```
$ sudo ./setup_sdcard.sh --probe-mmc
```

4. Install image on SD card, where /dev/sdX is the location of the SD Card

```
$ sudo ./setup_sdcard.sh --mmc /dev/sdX --dtb beaglebone
```

## Installation of RIAPS Base Configuration on Pre-configured BBB

1. With the SD Card installed in the BBB, log into the BBB using ssh with user account being 'ubuntu'

2. Download [baseImageInstall.tar.gz] to the BBB. 

3. On the BBB, unpack the installation and move into the package

```
$ tar -xzvf baseImageInstall.tar.gz
$ cd baseImage
```

4. Move to 'root' user

```
    $ sudo su
```

5. Run the installation script. Provide the name of the ssh key pair added in step 5, your key filename can be any name desired. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
$./base_bbb_bootstrap.sh 2>&1 | tee install-bbb.log
```

Note:  If RIAPS packages do not install, do the following outside of the script.  Then go back and only do the last function (setup_ssh_keys)

```
$ sudo apt-key add riapspublic.key 
$ sudo apt-get update
```

6. Remove public key from .ssh directory

7. Remove install files from /home/ubuntu

8. Place https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install_bbb.sh in /home/riaps/ to allow updating of the RIAPS platform by script

9. Reboot the Beaglebone Black

```
$ reboot
```

10. When the BBB is rebooted, you can ssh using the following:

```
Username:  riaps
Password:  riaps
```

## Saving Image

1. Copy the card to host:  sudo dd if=/dev/disk2 of=bbb_base_20170718.img  (check which disk with 'diskutil list')
2. Use https://etcher.io/ tool to copy from host to SD card


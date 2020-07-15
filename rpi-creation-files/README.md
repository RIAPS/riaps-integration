# Create Raspberry Pi 4 Base Image (4GB)

These are instructions on how the Raspberry Pi (RPi) 4 Base image was created.  

## Start with Ubuntu Pre-configured Image from Ubuntu

1) Download a complete pre-configured image (Ubuntu 18.04.4, RPi 4, 64 bit) onto the SD Card from https://ubuntu.com/download/raspberry-pi. Choose the latest version available.  Note: current download of RPi 4 and RPi 3 seem to be the same.

2) Unpack image and change into the directory (unxz file, then tar xf)

3) Install image on SD card

## Installation of RIAPS Base Configuration on Pre-configured RPi

1) With the SD Card installed in the RPi, log into using ssh with user account being 'ubuntu'.  
```
Username:  ubuntu
Password:  ubuntu
Kernel:    5.3.0-1017-raspi2 #19~18.04.1-Ubuntu
```

You will be asked to create a new password and will need ssh again into the device.

2) Download and compress the [rpi-creation-files folder](https://github.com/RIAPS/riaps-integration/tree/master/rpi-creation-files) and transfer it to the RPi.

3) On the RPi, unpack the creation files and move into the folder

```
tar -xzvf rpi-creation-files.tar.gz
cd rpi-creation-files
```

4) Create a swapfile on the RPi to allow larger packages to run (such as spdlog).  Instructions used for this are at http://manpages.ubuntu.com/manpages/focal/man8/dphys-swapfile.8.htmls

    a) ```sudo apt-get install dphys-swapfile```

    b) Edit /etc/dphys-swapfile to adjust default settings

       ```
       CONF_SWAPFILE=/var/swap
       CONF_SWAPSIZE=1024
       CONF_MAXSWAP=2048
       ```

    c) Turn on swapfile

       ```
       sudo /sbin/dphys-swapfile setup
       sudo /sbin/dphys-swapfile swapon
       ```

5) Reboot the RPi and still sign in as 'ubuntu'

6) Move to 'root' user

```
sudo su
```

7) Add 'ubuntu' hostname to the /etc/hosts file. Add following line to the file.

```
127.0.0.1 ubuntu
```

8) Run the installation script. Provide the name of the ssh key pair added in step 5, your key filename can be any name desired. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
cd riaps-integration/rpi-creation-files/
./base_rpi_bootstrap.sh 2>&1 | tee install-rpi.log
```

9) Remove install files from /home/ubuntu

10) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install_bbb.sh) in /home/riaps/ to allow updating of the RIAPS platform by script

11) Optional:  Remove the swapfile.  If you want to compile large third party libraries on this platform later, leave the swapfile (it does cost file space).

```
sudo /sbin/dphys-swapfile swapoff
```

12) Reboot RPi and sign in as 'riaps' user

```
Username:  riaps
Password:  riaps
```

13) Remove the 'ubuntu' user

```
sudo su
userdel -r ubuntu
exit
```

14) Add the RIAPS packages to the BBBs by using the following command (on the BBB).

```bash
./riaps_install_bbb.sh 2>&1 | tee install-bbb-riaps.log
```

15) Remove the 'ubuntu' host name from the /etc/hosts file

16) Reboot RPi to start the RIAPS services


### Usage of BBB Image

Users of this image will ssh using the following:

```
Username:  riaps
Password:  riaps
```

The device hostname will be "riaps-xxxx", where xxxx is the first four digits of the
board MAC address (so it will be unique per device).  Note: Beaglebone blacks used a
hostname of "bbb-xxxx".

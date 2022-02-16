# Create Raspberry Pi 4 Base Image (4GB)

These are instructions on how the Raspberry Pi (RPi) 4 Base image was created (arm64 architecture).  If you are creating an image for a Raspberry Pi 3, the architecture type would be armhf (32 bit architecture) similar to the Beaglebone Black.

## Start with Ubuntu Pre-configured Image from Ubuntu

1) Download a complete pre-configured image (Ubuntu 20.04.3, RPi 4, 64 bit) onto the SD Card from https://ubuntu.com/download/raspberry-pi. Choose the latest server version available.  

2) Unpack image and change into the directory (unxz file, then tar xf)

3) Install image on SD card, can use [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/) and install the "custom" .img file that was downloaded (in order to utilize the 64 bit version).

> Note: 4GB SD Card is too small, please consider a larger size card.

## Installation of RIAPS Base Configuration on Pre-configured RPi

1) With the SD Card installed in the RPi, log into using ssh with user account being 'ubuntu'.  
```
Username:  ubuntu
Password:  ubuntu
Kernel:    5.4.0-1042-raspi
```

You will be asked to create a new password and will need ssh again into the device.

2) Download and compress the [riaps-node-creation folder](https://github.com/RIAPS/riaps-integration/tree/master/riaps-node-creation) and transfer it to the RPi.

3) On the RPi, unpack the creation files and move into the folder

```
tar -xzvf riaps-node-creation.tar.gz
cd riaps-node-creation
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

8) Move back into the riaps-node-creation folder and run the installation script. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
cd riaps-node-creation
./base_rpi_bootstrap.sh 2>&1 | tee install-rpi.log
```

> Note: Due to unattended package updating, the script may need to be started 5-10 mins after starting the processor.  This step takes about an hour to run.

9) Remove install files from /home/ubuntu

10) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script. Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

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

14) Remove 'ubuntu' hostname from the /etc/hosts file (following line).

```
127.0.0.1 ubuntu
```

15) Enable 'cgroups' for cpu and memory resource management, along with apparmor for security:

    a) For 18.04 modify '/boot/firmware/nobtcmd.txt' or for 20.04, modify '/boot/firmware/cmdline.txt'

    b) Add “cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 security=apparmor" to the end of the command line.

    c) After rebooting, use "grep mem /proc/cgroups" to show that cgroup memory is enabled (last number will be 1).

16) Optional: Add SPI capability (which can be used for CAN communication)

    Edit the `/boot/firmware/usercfg.txt` file to add the following:

```
    dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25
    dtoverlay=spi-bcm2835-overlay
```

17) Optional: Turn off unattended package updates by editing /etc/apt/apt.conf.d/20auto-upgrades and set the "Unattended-Upgrade" to "0".

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";
```

18) Optional: Add the RIAPS packages to the Raspberry Pi 4 by using the following command (on the Pi).

```bash
./riaps_install_node.sh "arm64" 2>&1 | tee install-node-riaps.log
```

- Reboot RPi to start the RIAPS services

> Note: Release images do not include the RIAPS packages installed.

19) Optional: Resize the image to 8 MB for release posting

    a) Install 'gparted'

    b) Become root user - 'sudo su'

    c) Start 'gparted'

    d) Unmount the device (i.e. /dev/sdb)

    e) Resize to 8192 MiB

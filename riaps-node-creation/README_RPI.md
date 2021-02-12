# Create Raspberry Pi 4 Base Image (4GB)

These are instructions on how the Raspberry Pi (RPi) 4 Base image was created.  

## Start with Ubuntu Pre-configured Image from Ubuntu

1) Download a complete pre-configured image (Ubuntu 18.04.4, RPi 4, 64 bit) onto the SD Card from https://ubuntu.com/download/raspberry-pi. Choose the latest version available.  

> Note: current download of RPi 4 and RPi 3 seem to be the same.

2) Unpack image and change into the directory (unxz file, then tar xf)

3) Install image on SD card, can use [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/) and install the "custom" .img file that was downloaded (in order to utilize the 64 bit version).

> Note: 4GB SD Card is too small, please consider a larger size card.

## Add Real Time Patch to Kernel Image

This part can be performed on the RIAPS VM (ubuntu system with good computing power), not on the Raspberry Pi system.

Build a Real-time kernel for Raspberry Pi 4B using the instructions from https://lemariva.com/blog/2019/09/raspberry-pi-4b-preempt-rt-kernel-419y-performance-test.

1) Utilize a Ubuntu host system (such as a VM) to create this kernel image.

2) Install "bison" apt package on the Ubuntu host.

3) Setup configurations for the Toolchain and Kernel Configuration.

4) Compile the Kernel.

5) Transfer the packaged kernel to the Raspberry Pi 4 that was configured in the previous steps.

    ```
    scp rt-kernel.tgz ubuntu@<ipaddress>:/tmp
    ```

6) Install the Kernel Image, Modules & Device Tree Overlays (per instructions)

  Installed kernel:  4.19.71-rt24-v7l+

>MM TODO:  Installing the kernel indicates to modify the /boot/config.txt file to identify the new kernel (kernel=kernel7_rt.img). But the original image downloaded is a 5.3 kernel and the boot process has changed, there is now a u-boot sequence and the change needs to be in /boot/firmware.  Stopped here to figure out what to do.

> MM TODO: this did not work, issue with kernel version

## Installation of RIAPS Base Configuration on Pre-configured RPi

1) With the SD Card installed in the RPi, log into using ssh with user account being 'ubuntu'.  
```
Username:  ubuntu
Password:  ubuntu
Kernel:    5.4.0-1028-raspi
```

You will be asked to create a new password and will need ssh again into the device.

3) Download and compress the [riaps-node-creation folder](https://github.com/RIAPS/riaps-integration/tree/master/riaps-node-creation) and transfer it to the RPi.

4) On the RPi, unpack the creation files and move into the folder

```
tar -xzvf riaps-node-creation.tar.gz
cd riaps-node-creation
```

5) Create a swapfile on the RPi to allow larger packages to run (such as spdlog).  Instructions used for this are at http://manpages.ubuntu.com/manpages/focal/man8/dphys-swapfile.8.htmls

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

6) Reboot the RPi and still sign in as 'ubuntu'

7) Move to 'root' user

```
sudo su
```

8) Add 'ubuntu' hostname to the /etc/hosts file. Add following line to the file.

```
127.0.0.1 ubuntu
```

9) Move back into the riaps-node-creation folder and run the installation script. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
cd riaps-node-creation
./base_rpi_bootstrap.sh 2>&1 | tee install-rpi.log
```

> Note: Due to unattended package updating, the script may need to be started 5-10 mins after starting the processor.  This step takes about an hour to run.

10) Remove install files from /home/ubuntu

11) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script.  Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

12) Optional:  Remove the swapfile.  If you want to compile large third party libraries on this platform later, leave the swapfile (it does cost file space).

```
sudo /sbin/dphys-swapfile swapoff
```

13) Reboot RPi and sign in as 'riaps' user

```
Username:  riaps
Password:  riaps
```

14) Remove the 'ubuntu' user

```
sudo su
userdel -r ubuntu
exit
```

15) Remove 'ubuntu' hostname from the /etc/hosts file (following line).

```
127.0.0.1 ubuntu
```

16) Enable 'cgroups' for cpu and memory resource management:

    a) For 18.04 modify '/boot/firmware/nobtcmd.txt' or for 20.04, modify '/boot/firmware/cmdline.txt'

    b) Add “cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1” to the end of the command line.

    c) After rebooting, use "grep mem /proc/cgroups" to show that cgroup memory is enabled.

17) Optional: Add the RIAPS packages to the Raspberry Pi 4 by using the following command (on the Pi).

```bash
./riaps_install_node.sh "arm64" 2>&1 | tee install-node-riaps.log
```

- Reboot RPi to start the RIAPS services

> Note: Release images do not include the RIAPS packages installed.

18) Optional: Resize the image to 8 MB for release posting

    a) Install 'gparted'
    b) Become root user - 'sudo su'
    c) Start 'gparted'
    d) Unmount the device (i.e. /dev/sdb)
    e) Resize to 8192 MiB

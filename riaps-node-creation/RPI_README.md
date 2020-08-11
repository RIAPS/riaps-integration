# Create Raspberry Pi 4 Base Image (4GB)

These are instructions on how the Raspberry Pi (RPi) 4 Base image was created.  

## Start with Ubuntu Pre-configured Image from Ubuntu

1) Download a complete pre-configured image (Ubuntu 18.04.4, RPi 4, 64 bit) onto the SD Card from https://ubuntu.com/download/raspberry-pi. Choose the latest version available.  

> Note: current download of RPi 4 and RPi 3 seem to be the same.

2) Unpack image and change into the directory (unxz file, then tar xf)

3) Install image on SD card, can use [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/) and install the "custom" .img file that was downloaded (in order to utilize the 64 bit version).

## Installation of RIAPS Base Configuration on Pre-configured RPi

> Note: 4GB SD Card is too small, please consider a larger size card.

1) With the SD Card installed in the RPi, log into using ssh with user account being 'ubuntu'.  
```
Username:  ubuntu
Password:  ubuntu
Kernel:    5.3.0-1017-raspi2 #19~18.04.1-Ubuntu
```

You will be asked to create a new password and will need ssh again into the device.

> MM TODO: this did not work, issue with kernel version

2) Build a Real-time kernel for Raspberry Pi 4B using the instructions from https://lemariva.com/blog/2019/09/raspberry-pi-4b-preempt-rt-kernel-419y-performance-test.

    a) Utilize a Ubuntu host system (such as a VM) to create this kernel image.

    b) Install "bison" apt package on the Ubuntu host.

    c) Transfer the packaged kernel to the Raspberry Pi 4 that was configured in the previous steps.

        ```
        scp rt-kernel.tgz ubuntu@<ipaddress>:/tmp
        ```

    d) Install the Kernel Image, Modules & Device Tree Overlays (per instructions)

      Installed kernel:  4.19.71-rt24-v7l+

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

9) Run the installation script. Provide the name of the ssh key pair added in step 5, your key filename can be any name desired. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
cd riaps-node-creation
./base_rpi_bootstrap.sh 2>&1 | tee install-rpi.log
```

> Note: Due to unattended package updating, the script may need to be started 5-10 mins after starting the processor.  This step takes about an hour to run.

10) Remove install files from /home/ubuntu

11) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script

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

17) Add the RIAPS packages to the Raspberry Pi 4 by using the following command (on the Pi).

```bash
./riaps_install_node.sh "arm64" 2>&1 | tee install-node-riaps.log
```

18) Reboot RPi to start the RIAPS services


## Updated Real-time enabled Kernel

Once rebooted, the node's kernel will be (using `uname -a`)

```
Kernel: TBD
```

>TODO: add instructions for Real-time kernel update

https://lemariva.com/blog/2019/09/raspberry-pi-4b-preempt-rt-kernel-419y-performance-test

install bison

Installed kernel:  4.19.71-rt24-v7l+

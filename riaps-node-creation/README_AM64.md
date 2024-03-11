# Create RIAPS AM64x Base Image (??GB)

These are instructions on how the AM64x Base image can be created from a Debian pre-configured image.  

## Start with Debian Pre-configured Image from TI

This work should be done on a Linux machine or VM. We are starting with a pre-configured AM64x Debian image and any other customizations needed for RIAPS.

1) Download a complete pre-configured image (Debian 12 - Bookworm) onto a SD Card - https://www.ti.com/tool/PROCESSOR-SDK-AM64X.  Choose the latest version available.  Download the "tisdk-debian-bookworm-am64xx-evm.wic.xz".

2) Use `balenaEtcher` to copy the image to the SD card

Resulting image information:

```
Username:  root
Password:  <none>
Kernel:    v6.1.xx-rtxx-k3-rt
```

## Installation of RIAPS Base Configuration on Pre-configured AM64x

1) With the SD Card installed in the AM64x, log in using ssh with user account being 'root'
   
2) Update the locales using `dpkg-reconfigure locales` and selecting `en_US:en UTF-8` option.

3) Download and compress the [riaps-node-creation folder](https://github.com/RIAPS/riaps-integration/tree/master/riaps-node-creation) and transfer it to the AM64x.

4) On the AM64x, unpack the creation files and move into the folder

```
tar -xzvf riaps-node-creation.tar.gz
cd riaps-node-creation
```

4) Run the installation script. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
./base_am64_bootstrap.sh 2>&1 | tee install-am64.log
```

> Note: this step takes about ??? hours to run

5) Remove install files from /home/root

6) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script. Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

7)  Reboot BBB and sign in as 'riaps' user

>Note: MM TODO: stopped editing changes here
8) Optional: Add SPI capability (which can be used for CAN communication)

    Edit the `/boot/uEnv.txt` file to add the following (as appropriate to the SPI port desired):

```
    ###Additional custom capes  
    uboot_overlay_addr4=/lib/firmware/BB-SPIDEV0-00A0.dtbo  
```

9) Optional: Turn off unattended package updates by editing /etc/apt/apt.conf.d/20auto-upgrades and set the "Unattended-Upgrade" to "0".

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "0";
```

10) Optional: Add the RIAPS packages to the BBBs by using the following command (on the AM64x).

```
./riaps_install_node.sh "arm64" 2>&1 | tee install-node-riaps.log
```

- Reboot AM64 to start the RIAPS services

> Note: Release images do not include the RIAPS packages installed.

# Create NVIDIA Jetson Nano Base Image (4GB)

These are instructions on how the NVIDIA Jetson Nano base image was created.  

> Note: these instructions have not yet been updated for the Ubuntu 20.04 release

## Start with Ubuntu Pre-configured Image from NVIDIA

1) Begin with the [Getting Started with Jetson Nano Developer Kit](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit) to find the base image (jetson-nano-developer-kit-sd-card-image.zip).

2) Install downloaded zip file to SD Card.

3) On first boot with the new SD Card, the Jetson Nano must be hooked up to a HDMI monitor with a keyboard and mouse in order to perform the system configuration steps.

    a) NVIDIA End User License Agreement, language and timezone setups.

    b) Computer and user name configuration - create a 'riapsadmin' user with password of 'riapsadmin' and set computer name to `riaps-nano`.

    c) Use the default APP partition size.

    d) System will update packages and then shutdown.

4) The device is now ready to be logged into without a display, so make sure the device is connected using ethernet to the router used to communicate between the VM and remote nodes.

## Add Real Time Patch to Kernel Image

This part can be performed on the RIAPS VM (ubuntu system with good computing power), not on the Jetson Nano.

> MM TODO:  Found instructions at https://forums.developer.nvidia.com/t/preempt-rt-patches-for-jetson-nano/72941/31.  Have not tried it yet.

## Installation of RIAPS Base Configuration on Pre-configured Nano

1) With the SD Card installed in the Jetson Nano, log into using ssh with user account being 'riapsadmin'.  
```
Username:  riapsadmin
Password:  riapsadmin
Kernel:    4.9.140-tegra #1 SMP PREEMPT Thu Jun 25 21:25:44 PDT 2020 aarch64 aarch64 aarch64 GNU/Linux
Distribution: Ubuntu 18.04.4 LTS (bionic)
```

2) Create a swapfile on the Jetson Nano to allow larger packages to run (such as spdlog).  Instructions used for this are at https://medium.com/@heldenkombinat/getting-started-with-the-jetson-nano-37af65a07aab#4098.

    ```
    sudo fallocate -l 4G /var/swapfile
    sudo chmod 600 /var/swapfile
    sudo mkswap /var/swapfile
    sudo swapon /var/swapfile
    sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'
    ```

    To check that everything worked correctly run 'free -h'. Swap should show 4,0G or whatever other size you've chosen for the swap file.

3) Download and compress the [riaps-node-creation folder](https://github.com/RIAPS/riaps-integration/tree/master/riaps-node-creation) and transfer it to the Jetson Nano.

4) On the Jetson Nano, unpack the creation files and move into the folder

```
tar -xzvf riaps-node-creation.tar.gz
cd riaps-node-creation
```

5) Move to 'root' user

```
sudo su
```

6) Run the installation script. The 'tee' with a filename (and 2>&1) allows you to record the installation process and any errors received. If you have any issues during installation, this is a good file to send with your questions.

```
./base_nano_bootstrap.sh 2>&1 | tee install-nano.log
```

> Note: This step takes about 40 mins to run.

7) Remove install files from /home/riapsadmin

8) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script. Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

9) Reboot RPi and sign in as 'riaps' user

```
Username:  riaps
Password:  riaps
```

10) Remove the 'riapsadmin' user

```
sudo su
userdel -r riapsadmin
exit
```

11) Place the [RIAPS Install script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-runtime/riaps_install_node.sh) in /home/riaps/ to allow updating of the RIAPS platform by script.  Change the owner (sudo chown) to 'riaps:riaps' and mode to add execution (sudo chmod +x).

12) Optional: Add the RIAPS packages to the Jetson Nano by using the following command (on the Nano).

```
./riaps_install_node.sh "arm64" 2>&1 | tee install-node-riaps.log
```

- Reboot Jetson Nano to start the RIAPS services

> Note: Release images do not include the RIAPS packages installed.

> Note: 32 GB image and Swap file is left enabled on the image since this image will likely be used with machine learning activities. Current used image size is 58% (or ~18 GiB) before RIAPS package installation.

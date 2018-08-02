# Initial Setup of Vagrant on a Host Machine

For first time setup, following these steps to configure your system to run Vagrant and the associated plugins:

1. Download and install Oracle VirtualBox from https://www.virtualbox.org/.  Use version 5.1.12 or later.

2. Download and install the virtual box extensions pack. Make sure that the extensions pack is the same version as your virtual box installation. Review https://www.virtualbox.org/wiki/Downloads for details.

3. Download and install Vagrant from https://www.vagrantup.com/

4. Install the Vagrant plugin for VirtualBox Guest Additions. This command is issued from a command line window on the host machine.  The base box used comes with the Guest Additions for 5.0.18, and the plugin will take care to install the correct Guest Additions if your version of VirtualBox differs from that.   

```bash
vagrant plugin install vagrant-vbguest
```

5. Install the Vagrant scp plugin.  This command is issued from a command line window on the host machine.  

```bash
vagrant plugin install vagrant-scp
```  

# Initial Installation of RIAPS Specific Virtual Machine

1. Download the RIAPS development box setup file: [riaps-x86runtime.tar.gz](https://github.com/RIAPS/riaps-integration/releases). Then, unzip it and change into that directory in the command line window.  

2. If you want to have your own ssh keys installed initially, download your rsa ssh key pair (.pub and .key) to the same directory.  If you do not have any specific keys you would like to use, keys will be automatically generated for you.  The key name must be **id_rsa.pub** and **id_rsa.key**.  The same key pair will be used on the host development machine (VM) and the BBB.

3. Then issue the command from the file folder with the vagrant information (unzipped in the previous step).  This command will run a script in the command line window to setup the Virtual Machine for the RIAPS platform.  The 'tee' with a filename allows you to record the installation process and any errors on a Linux system.  If you have any issues during installation, this is a good file to send with your questions.  

```bash
vagrant up 2>&1 | tee install-vm.log
```

4. When asked which network interface to use, pick the most appropriate to your system configuration which will give you internet access.

5. The VM will launch with a username of vagrant.  Select the **RIAPS App Developer** username.  

    - **The default password for RIAPS App Developer is 'riaps'**
    - **The password for vagrant user is 'vagrant'**

    <br/>
    
    > Note:  The initial installation will take some time to complete and will continue in a command line window.  Wait for this step to complete before continuing on to the next steps.

6. After the vagrant script completes, setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

- Determine the desired ethernet interface
    
```bash
ifconfig
```   
    
- Edit the riaps configuration to enable that interface
    
```bash
sudo nano /usr/local/riaps/etc/riaps.conf
```   
    
- Make sure the NIC name and match the desired ethernet interface name from 'ifconfig'

```python
# NIC name
# Typical VM interface
#nic_name = eth0
nic_name = enp0s8
```

7. Save your SSH keys in a secure spot for use in the future (if needed)
    - Copy your ~/.ssh/id_rsa.pub and ~/.ssh/id_rsa.key files to a location you can find in the future, preferably in a location outside the VM.

8.  Eclipse has been install for this host.  It is a good idea to periodically update the software to get the latest RIAPS (and others) tools.  To do this, go to the **Help** menu and select **Check for Updates**.  When asked for login, hit **Cancel**, updates will start anyway.

# [Securing Communication Between the VM and BBBs](#SecureComm)
Once all the initial BBB configuration is complete, you can run the following script on the VM to secure the communication between the VM and the BBB with the ssh keys configured on your VM.  Where **xxx&#46;xxx&#46;xxx&#46;xxx** is the IP address of the BBB on your network.  Make sure you are logged in as **riaps** user.  This will need to be repeated for all BBBs (or use a fabric script to assist)

```bash
./secure_keys.sh bbb_initial_keys/bbb_initial.key ~/.ssh/id_rsa.key ~/.ssh/id_rsa.pub xxx.xxx.xxx.xxx
```
        
# Testing Development Environment Setup

To test your environment works with your BBBs, follow the instructions on [Environment Test Page](env_setup_tests/README.md).

# Installing Multiple Virtual Machines (if desired)
If you want to keep an older RIAPS Virtual Machine and install a new one, in the Vagrant file change the following to new names:

- config.vm.hostname = "riapsvbox"
- vb&#46;name = "riaps_vbox"   
    
# RIAPS Virtual Machine Update Process
If you have a running RIAPS VM and want to upgrade it, follow these steps:

- Make sure the VM is shutdown
- Update the contents of the 'riaps-x86runtime' folder used to create the original Virtual Machine with the latest release by downloading the RIAPS development box setup file: [riaps-x86runtime.tar.gz](https://github.com/RIAPS/riaps-integration/releases)
- In a command line window, go back to that 'riaps-x86runtime' folder 
- Bring up the VM and then provision the changes using the following commands.  The 'tee' with a filename allows you to record the installation process.  If you have any issues during installation, this is a good file to send with your questions.

```bash
vagrant up 
vagrant provision 2>&1 | tee update-vm.log
```   

# RIAPS Platform Update Process
If you want to only update the RIAPS platform, follow these steps:

1. Download the [RIAPS update script](riaps_install_amd64.sh) to the VM

2. Run the update script

```bash
./riaps_install_amd64.sh 2>&1 | tee install-riaps-update-vm.log
```
    
# Helpful Hints
1. If you need to remove a vagrant VM, go to the command line and type 

```bash
vagrant global-status
```
```text
id       name    provider   state    directory
-------------------------------------------------------------------------------
40d1606  default virtualbox running  /Users/xxx/VirtualBox VMs/riaps-x86runtime
```

2. Select the ID you want to delete and then type

```bash
vagrant destroy 40d1606
```
> Note: 40d1606 is the ID

3. Now you can create a VM of the same name again.
 
    

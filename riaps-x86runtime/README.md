# Initial Setup of Vagrant on a Host Machine

For first time setup, following these steps to configure your system to run Vagrant and the associated plugins:

1. Download and install Oracle VirtualBox from https://www.virtualbox.org/.  Use version 5.1.12 or later.
2. Download and install the virtual box extensions pack. Make sure that the extensions pack is the same version as your virtual box installation. Review https://www.virtualbox.org/wiki/Downloads for details.
3. Download and install Vagrant from https://www.vagrantup.com/
4. Install the Vagrant plugin for VirtualBox Guest Additions. This command is issued from a command line window on the host machine.  The base box used comes with the Guest Additions for 5.0.18, and the plugin will take care to install the correct Guest Additions if your version of VirtualBox differs from that. To do so simply call 

    ```
    vagrant plugin install vagrant-vbguest
    ```  

5. Install the Vagrant scp plugin.  This command is issued from a command line window on the host machine.  

    ```
    vagrant plugin install vagrant-scp
    ```  

# Initial Installation of RIAPS Specific Virtual Machine

1. Download the RIAPS development box setup file (riaps-x86runtime.tar.gz found at https://github.com/RIAPS/riaps-integration/releases), unzip it and change into that directory in the command line window.  

2. Download your rsa ssh key pair (.pub and .key) to the same directory.  If you need to generate keys, use the following command.  The same key pair should be used on the host development machine (VM) and the BBB.

	```
	cat id_generated_rsa >> authorized_keys
	```

3. Make sure the **Vagrantfile** points to your ssh keys, edit the file if necessary.  The key names are indicated at the end of the file.

	```
    from Vagrantfile:
    
    config.vm.provision "shell", :path => "bootstrap.sh", :args => "public_key=id_rsa.pub private_key=id_rsa.key"
	```

4. Then issue the command from the file folder with the vagrant information (unzipped in the previous step).  This command will run a script in the command line window to setup the Virtual Machine for the RIAPS platform.  The 'tee' with a filename allows you to record the installation process and any errors.  If you have any issues during installation, this is a good file to send with your questions.

	```
    vagrant up 2>&1 | tee install-vm.log
    ```   

5. When asked which network interface to use, pick the most appropriate to your system configuration.

6. The VM will launch with a username of vagrant.  Select the **RIAPS App Developer** username


    - **The default password for RIAPS App Developer is 'riaps'**
    - **The password for vagrant user is 'vagrant'**

7. After the vagrant script completes, setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

    - Determine the desired ethernet interface
    
        ```
        ifconfig
        ```   
    
    - Edit the riaps configuration to enable that interface
    
        ```
        sudo nano /etc/riaps/riaps.conf
        ```   
    
    - Uncomment the NIC name and match the desired ethernet interface name from 'ifconfig'
    
        ```
        # This is the main configuration file for RIAPS.  
        [RIAPS]

        # RIAPS target user name
        target_user = riaps

        # Timeout for send operations
        send_timeout = 1000

        # NIC name
        # nic_name = enp0s8
        ```   
        
# Installing Multiple Virtual Machines (if desired)
If you want to keep an older RIAPS Virtual Machine and install a new one, in the Vagrant file change the following to new names:
   - config.vm.hostname = "riapsvbox"
   - vb.name = "riaps_vbox"   
    
# RIAPS Virtual Machine Update Process
If you have a running RIAPS VM and want to upgrade it, follow these steps:

- Make sure the VM is shutdown
- Update the contents of the 'riaps_vbox' folder used to create the original Virtual Machine
- In a command line window, go back to that 'riaps_vbox' folder 
- Bring up the VM and then provision the changes using the following commands.  The 'tee' with a filename allows you to record the installation process.  If you have any issues during installation, this is a good file to send with your questions.

    ```
    vagrant up 
    vagrant provision 2>&1 | tee update-vm.log
    ```   

# RIAPS Update Process
If you want to only update the RIAPS platform, follow these steps:

1. Download the RIAPS update script (https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/riaps_install.sh) to the VM

2. Run the update script

	```
	./riaps_install.sh 2>&1 | tee install-riaps-update-vm.log
	```


# Initial Setup of Vagrant on a Host Machine

For first time setup, following these steps to configure your system to run Vagrant and the associated plugins:

- Download and install Oracle VirtualBox from https://www.virtualbox.org/.  Use version 5.1.12 or later.
- Download and install the virtual box extensions pack. Make sure that the extensions pack is the same version as your virtual box installation. Review https://www.virtualbox.org/wiki/Downloads for details.
- Download and install Vagrant from https://www.vagrantup.com/
- Install the Vagrant plugin for VirtualBox Guest Additions. This command is issued from a command line window on the host machine.  The base box used comes with the Guest Additions for 5.0.18, and the plugin will take care to install the correct Guest Additions if your version of VirtualBox differs from that. To do so simply call 

    ```
    vagrant plugin install vagrant-vbguest
    ```  

- Install the Vagrant scp plugin.  This command is issued from a command line window on the host machine.  

    ```
    vagrant plugin install vagrant-scp
    ```  

# Initial Installation of RIAPS Specific Virtual Machine

- Download the RIAPS development box setup file (riaps-x86runtime.tar.gz found at https://github.com/RIAPS/riaps-integration/releases), unzip it and change into that directory in the command line window.  

- Then issue the command from the file folder with the vagrant information (unzipped in the previous step).

    ```
    vagrant up
    ```   

- When asked which network interface to use, pick the most appropriate to your system configuration.

- The VM will launch with a username of vagrant.  Select the appropriate user name:  RIAPS App Developer 


    **The default password is riaps for both app developer. The password for vagrant user is vagrant.**

- Setup the Network Interface to select the interface connected to the router where remote RIAPS nodes will be attached.  

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
    
# RIAPS Virtual Machine Update Process
If you have a running RIAPS VM and want to upgrade it, follow these steps:

- Make sure the VM is shutdown
- Update the contents of the 'riaps_vbox' folder
- In a command line window, go back to the 'riaps_vbox' folder used to create the original VM
- Bring up the VM and then provision the changes

    ```
    vagrant up 
    vagrant provision
    ```   

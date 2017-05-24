
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

- Download the RIAPS development box setup file (found at https://riaps.isis.vanderbilt.edu/redmine/attachments/download/131/riapsdevbox.zip), unzip it and change into that directory in the command line window.  

- Then issue the command from the file folder with the vagrant information (unzipped in the previous step).


```
    vagrant up
```   

- When asked which network interface to use, pick the most appropriate to your system configuration.

- The VM will launch with a username of vagrant.  Select the appropriate user name:  RIAPS App Developer or RIAPS Platform Developer 


The default password is riaps for both app developer and platform developer. The password for vagrant user is vagrant.

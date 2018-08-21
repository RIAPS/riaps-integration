# Setting up the BBB images

1. Download the latest BBB image from the RIAPS Wiki.

    [BBB Base Image -  June 12, 2018](https://riaps.isis.vanderbilt.edu/redmine/attachments/download/286/riaps-bbb-base-20180612.zip)
    
2. Copy the image to the BBB SD Card using a host machine and an SD Card reader.  A good open source tool for transferring the image to a SD Card is https://etcher.io/.

3. Put the SD Card into the BBB and boot it up.

4. Log into the **riaps** account on the BBB.

5. Add the RIAPS packages to the BBBs by using the following command (on the BBB).

```bash
./riaps_install_bbb.sh 2>&1 | tee install-bbb-riaps.log
```	

6. You can ssh into the BBBs using the following:

    Username:  riaps<br/>
    Password:  riaps
    
```bash
ssh -i /home/riaps/.ssh/id_rsa.key riaps@XXX.XXX.XXX.XXX
```
>  where **xxx&#46;xxx&#46;xxx&#46;xxx** is the IP address of the BBB

<p align="center">or</p>
    
```bash
ssh -i /home/riaps/.ssh/id_rsa.key riaps@bbb-xxxx
```
> where **xxxx** is the hostname seen when logging into the BBBs

7. Secure communication between the Host Environment and the BBBs by following the [Securing Communication Between the VM and BBBs](https://github.com/RIAPS/riaps-integration/tree/master/riaps-x86runtime/README.md#securecomm) instructions.  Once this process completes, the host environment will automatically login to the beaglebones when using ssh by utilizing your ssh keys.

8. Reboot the BBBs
  
# Update RIAPS Platform Packages on Existing BBBs

1. Download the [RIAPS update script](https://github.com/RIAPS/riaps-integration/blob/master/riaps-bbbruntime/riaps_install_bbb.sh) to the BBB.

2. Stop the riaps_deplo service by running the kill script.

3. Run the update script.

```bash
sudo apt-get update
sudo apt-get install 'riaps-*' 2>&1 | tee install-riaps-update-bbb.log
```

# Helpful Hints 

1. If you try 'scp' or 'ssh' and receive the following message, remove the '~/.ssh/known_host' file and try again.

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:mX09UKLFyvo51pwSzd5IUapUlUVSxhPZZDZqGlBy4RY.
Please contact your system administrator.
Add correct host key in /home/riaps/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/riaps/.ssh/known_hosts:2
  remove with:
  ssh-keygen -f "/home/riaps/.ssh/known_hosts" -R 192.168.1.101
ECDSA host key for 192.168.1.101 has changed and you have requested strict checking.
Host key verification failed.
lost connection
```

# Available RIAPS Services

Current services loaded into the image on the BBB and on the host VM:

1. **riaps-deplo.service** - will start the RIAPS deployment application.  This service starts the RIAPS discovery service.  When enabled, this service is setup to restart if it fails.

   - this service is currently disabled on the VM by default
   - this service is currently enabled and started on the BBB by default

To see the status of a service or control its state, use the following commands manually on a command line, where name is the service name (like deplo).  Starting a service runs the actions immediately.  Enabling the service will allow the service to start when booting up.

```bash
sudo systemctl status riaps-<name>.service
sudo systemctl start riaps-<name>.service
sudo systemctl stop riaps-<name>.service
sudo systemctl enable riaps-<name>.service
sudo systemctl disable riaps-<name>.service
```


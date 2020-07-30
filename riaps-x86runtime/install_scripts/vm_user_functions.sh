#!/usr/bin/env bash
set -e


# Setup User Account
user_func () {
    if ! id -u $RIAPSUSER > /dev/null 2>&1; then
        echo ">>>>> The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSUSER -s /bin/bash -d /home/$RIAPSUSER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSUSER
        sudo chage -d 0 $RIAPSUSER
        sudo usermod -aG sudo $RIAPSUSER
        sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_apps
        echo ">>>>> created user accounts"
    fi
}

setup_ssh_keys () {
    # Setup user (or generated) ssh keys for VM
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.ssh
    sudo cp $PUBLIC_KEY /home/$RIAPSUSER/.ssh/id_rsa.pub
    sudo cp $PRIVATE_KEY /home/$RIAPSUSER/.ssh/id_rsa.key
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/id_rsa.pub
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/id_rsa.key
    sudo -H -u $RIAPSUSER cat /home/$RIAPSUSER/.ssh/id_rsa.pub >> /home/$RIAPSUSER/.ssh/authorized_keys
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/authorized_keys
    sudo -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.ssh/authorized_keys
    sudo -H -u $RIAPSUSER chmod 400 /home/$RIAPSUSER/.ssh/id_rsa.key
    echo "# RIAPS:  Add SSH keys to ssh agent on login" >> /home/$RIAPSUSER/.bashrc
    echo "ssh-add /home/$RIAPSUSER/.ssh/id_rsa.key" >> /home/$RIAPSUSER/.bashrc

    # Setup RIAPS ssh keys for use with VM
    sudo cp -r riaps_initial_keys /home/$RIAPSUSER/.
    sudo chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/riaps_initial_keys
    sudo -H -u $RIAPSUSER chmod 400 /home/$RIAPSUSER/riaps_initial_keys/riaps_initial.key
    #sudo -H -u $RIAPSUSER
    echo "ssh-add /home/$RIAPSUSER/riaps_initial_keys/riaps_initial.key" >> /home/$RIAPSUSER/.bashrc

    # Transfer RIAPS rekeying script
    sudo cp secure_keys /home/$RIAPSUSER/.
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/secure_keys
    sudo -H -u $RIAPSUSER chmod 700 /home/$RIAPSUSER/secure_keys
    echo ">>>>> Added user key to authorized keys for $RIAPSUSER. Use riaps_initial keys for initial communication with the remote RIAPS nodes"
}

add_set_tests () {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/env_setup_tests/WeatherMonitor
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/env_setup_tests/WeatherMonitor /home/$RIAPSUSER/env_setup_tests/
    sudo chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/env_setup_tests/WeatherMonitor
    echo ">>>>> Added development environment tests"
}

create_riaps_version_file () {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.riaps
    sudo echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Ubuntu Version: $CURRENT_UBUNTU_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}

set_riaps_sudoer () {
    echo "riaps  ALL=(ALL) NOPASSWD: ALL" >> riaps
    sudo mv riaps /etc/sudoers.d/.
    sudo chown root:root /etc/sudoers.d/riaps
    sudo chmod 0440 /etc/sudoers.d/riaps
    echo ">>>>> Added RIAPS to sudoer list"
}

add_eclipse_projects() {
    # Setup example projects file for use with eclipse to give developers a good starting projects
    git clone https://github.com/RIAPS/riaps-apps.git
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_projects
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-apps/apps-vu/DistributedEstimator /home/$RIAPSUSER/riaps_projects/.
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-apps/apps-vu/DistributedEstimatorGPIO /home/$RIAPSUSER/riaps_projects/.
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-apps/apps-vu/WeatherMonitor /home/$RIAPSUSER/riaps_projects/.
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_projects

    # Add eclipse launch files to user files
    git clone https://github.com/RIAPS/riaps-pycom.git
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_launch_files
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-pycom/bin/riaps_ctrl.launch /home/$RIAPSUSER/riaps_launch_files/.
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-pycom/bin/riaps_deplo.launch /home/$RIAPSUSER/riaps_launch_files/.
    sudo cp -r /home/riapsadmin/riaps-integration/riaps-x86runtime/riaps-pycom/bin/rpyc_registry.launch /home/$RIAPSUSER/riaps_launch_files/.
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_launch_files
    echo ">>>>> Added example RIAPS projects for eclipse use"
}

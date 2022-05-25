#!/usr/bin/env bash
set -e


user_func() {
    if ! id -u $RIAPSUSER > /dev/null 2>&1; then
        echo ">>>>> The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSUSER -s /bin/bash -d /home/$RIAPSUSER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSUSER
        sudo usermod -aG sudo $RIAPSUSER
        sudo usermod -aG dialout $RIAPSUSER
        sudo usermod -aG gpio  $RIAPSUSER
        sudo usermod -aG pwm $RIAPSUSER
        sudo usermod -aG spi $RIAPSUSER        
        sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_apps
        cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
        echo ">>>>> created user accounts"
    fi
}

# This function requires that riaps_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-node-creation/riaps_initial_keys/id_rsa.pub
# be placed on the remote node as this script is run
setup_ssh_keys() {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.ssh
    sudo -H -u $RIAPSUSER cat riaps_initial_keys/riaps_initial.pub >> /home/$RIAPSUSER/.ssh/authorized_keys
    chmod 600 /home/$RIAPSUSER/.ssh/authorized_keys
    chown -R $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh
    echo ">>>>> Added unsecured public key to authorized keys for $RIAPSUSER"
}

# Create a file that tracks the version installed on the RIAPS node, will help in debugging efforts
create_riaps_version_file () {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.riaps
    sudo echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Ubuntu Version: $UBUNTU_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}

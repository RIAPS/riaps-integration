#!/usr/bin/env bash
set -e


user_func() {
    if ! id -u $RIAPSAPPDEVELOPER > /dev/null 2>&1; then
        echo "The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSAPPDEVELOPER -s /bin/bash -d /home/$RIAPSAPPDEVELOPER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSAPPDEVELOPER
        getent group gpio || sudo groupadd gpio
        sudo usermod -aG sudo $RIAPSAPPDEVELOPER
        sudo usermod -aG dialout $RIAPSAPPDEVELOPER
        sudo usermod -aG gpio  $RIAPSAPPDEVELOPER
        sudo usermod -aG pwm $RIAPSAPPDEVELOPER
        sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/riaps_apps
        cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
        echo "created user accounts"
    fi
}


# This function requires that bbb_initial.pub from https://github.com/RIAPS/riaps-integration/blob/master/riaps-x86runtime/bbb_initial_keys/id_rsa.pub
# be placed on the bbb as this script is run
setup_ssh_keys() {
    sudo -H -u $RIAPSAPPDEVELOPER mkdir -p /home/$RIAPSAPPDEVELOPER/.ssh
    sudo -H -u $RIAPSAPPDEVELOPER cat bbb_initial_keys/bbb_initial.pub >> /home/$RIAPSAPPDEVELOPER/.ssh/authorized_keys
    chmod 600 /home/$RIAPSAPPDEVELOPER/.ssh/authorized_keys
    chown -R $RIAPSAPPDEVELOPER:$RIAPSAPPDEVELOPER /home/$RIAPSAPPDEVELOPER/.ssh
    echo "Added unsecured public key to authorized keys for $RIAPSAPPDEVELOPER"
}

#!/usr/bin/env bash
set -e

user_func() {
    if ! id -u $RIAPSUSER > /dev/null 2>&1; then
        echo ">>>>> The user does not exist; setting user account up now"
        sudo useradd -m -c "RIAPS App Developer" $RIAPSUSER -s /bin/bash -d /home/$RIAPSUSER
        sudo echo -e "riaps\nriaps" | sudo passwd $RIAPSUSER
        sudo chmod 0755 /home/$RIAPSUSER
        getent group gpio || sudo groupadd gpio
        getent group dialout || sudo groupadd dialout
        getent group pwm || sudo groupadd pwm
        sudo usermod -aG sudo $RIAPSUSER
        sudo usermod -aG dialout $RIAPSUSER
        sudo usermod -aG gpio  $RIAPSUSER
        sudo usermod -aG pwm $RIAPSUSER
        sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_apps
        cp etc/sudoers.d/riaps /etc/sudoers.d/riaps
        sudo mkdir -p /home/$RIAPSUSER/.ssh
        sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh
        echo ">>>>> created user accounts"
    fi
}

add_spi_func() {
    getent group spi || sudo groupadd spi
    sudo usermod -aG spi $RIAPSUSER
    sudo chown :spi /dev/spidev0.0
    sudo chmod g+rw /dev/spidev0.0
    sudo chown :spi /dev/spidev0.1
    sudo chmod g+rw /dev/spidev0.1
}

# Create a file that tracks the version installed on the RIAPS node, will help in debugging efforts
create_riaps_version_file () {
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.riaps
    sudo echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "$LINUX_DISTRO Version: $LINUX_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "$LINUX_DISTRO Package: $CURRENT_PACKAGE_REPO" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
    sudo -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt
    echo ">>>>> Created RIAPS version log file"
}

#!/usr/bin/env bash
set -e


# Script functions
check_os_version() {
    # Check that the intended host architecture is really what is setup here, if not then stop installation.
    host_architecture="$(dpkg --print-architecture)"
    echo ">>>>> VM arch: $host_architecture"
    echo ">>>>> Requested arch: $HOST_ARCH"
    if [ "$host_architecture" = "$HOST_ARCH" ]; then
        echo ">>>>> Host architecture intended for installation matches the VM architecture."
    else
        echo ">>>>> Host architecture intended for installation does not matches the VM architecture, please correct and start again."
        exit
    fi

    # The installation fails if the requested OS version is not the same as the VM version or is not
    # in the list of available versions
    VALID_SETUP=0
    HOST_OS_VERSION="$(lsb_release -sr | cut -d ' ' -f 1)"
    echo ">>>>> VM OS: $HOST_OS_VERSION"
    echo ">>>>> Requested OS: $UBUNTU_VERSION_INSTALL"
    for version in ${UBUNTU_VERSION_OPTS[@]}; do
        if [ "$version" = "$UBUNTU_VERSION_INSTALL" ] && [ "$version" = "$HOST_OS_VERSION" ]; then
            VALID_SETUP=1
        fi
    done

    if [ $VALID_SETUP == 1 ]; then
        echo ">>>>> System setup is valid, installation will begin."
    else
        echo ">>>>> System setup is invalid, choose Ubuntu version that is available (${UBUNTU_VERSION_OPTS[*]})."
        exit
    fi
}

# Required for riaps-timesync
# Assumes libnss-mdns is already installed
timesync_requirements() {
    sudo apt-get install linuxptp gpsd chrony -y
    sudo apt-get install  libssl-dev libffi-dev -y
    sudo apt-get install rng-tools -y
    sudo systemctl start rng-tools.service
    echo ">>>>> installed timesync requirements"
}

watchdog_timers() {
    echo " " >> /etc/sysctl.conf
    echo "###################################################################" >> /etc/sysctl.conf
    echo "# Enable Watchdog Timer on Kernel Panic and Kernel Oops" >> /etc/sysctl.conf
    echo "# Enable OOM-Killer" >> /etc/sysctl.conf
    echo "# Added for RIAPS Platform (10/25/21, MM)" >> /etc/sysctl.conf
    echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
    echo "kernel.panic = 5" >> /etc/sysctl.conf
    echo "vm.oom-kill = 1" >> /etc/sysctl.conf
    echo ">>>>> added watchdog timer values"
}

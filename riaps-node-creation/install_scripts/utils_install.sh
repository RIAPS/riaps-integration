#!/usr/bin/env bash
set -e

# Needed to allow apt-get update to work properly
rdate_install() {
    sudo apt-get install rdate -y
    sudo rdate -n -4 time.nist.gov
    echo ">>>>> installed rdate"
}

vim_func() {
    sudo apt-get install vim -y
    echo ">>>>> installed vim"
}

htop_install() {
    sudo apt-get install htop -y
    echo ">>>>> installed htop"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo ">>>>> snap package manager removed"
}

nano_install() {
    sudo apt-get install nano -y
    echo ">>>>> installed nano"
}

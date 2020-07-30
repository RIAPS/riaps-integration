#!/usr/bin/env bash
set -e

utils_install() {
    sudo apt-get install htop -y
    sudo apt-get install openssl openssh-server -y
    sudo apt-get install mininet -y
    # make sure date is correct
    sudo apt-get install rdate -y
    # rdate command can timeout, restart script from here if this happens
    sudo rdate -n -4 time.nist.gov
    echo ">>>>> installed utils"
}

vim_func() {
    sudo apt-get install vim -y
    echo ">>>>> installed vim"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo ">>>>> snap package manager removed"
}

java_func () {
    sudo apt-get install openjdk-11-jre-headless -y
    echo ">>>>> installed java"
}

#eclipse install
eclipse_shortcut() {
    shortcut=/home/$RIAPSUSER/Desktop/Eclipse.desktop
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/Desktop
    sudo -H -u $RIAPSUSER cat <<EOT >$shortcut
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Eclipse
Name[en_US]=Eclipse
Icon=/home/$RIAPSUSER/eclipse/icon.xpm
Exec=/home/$RIAPSUSER/eclipse/eclipse -data /home/$RIAPSUSER/workspace
EOT

    sudo chmod +x /home/$RIAPSUSER/Desktop/Eclipse.desktop
}

eclipse_func() {
    if [ ! -d "/home/$RIAPSUSER/eclipse" ]
    then
       wget http://www.eclipse.org/downloads/download.php?file=/oomph/epp/oxygen/R2/eclipse-inst-linux64.tar.gz
       tar -xzvf eclipse-inst-linux64.tar.gz
       sudo mv eclipse /home/$RIAPSUSER/.
       sudo chown -R $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/eclipse
       sudo -H -u $RIAPSUSER chmod +x /home/$RIAPSUSER/eclipse/eclipse
       eclipse_shortcut $RIAPSUSER
    else
       echo ">>>>> eclipse already installed at /home/$RIAPSUSER/eclipse"
    fi
}

# Dependencies for RIAPS eclipse plugin
eclipse_plugin_dep_install() {
    sudo apt-get install clang-format -y
    echo ">>>>> installed eclipse dependencies"
}

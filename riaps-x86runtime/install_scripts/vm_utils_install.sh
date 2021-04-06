#!/usr/bin/env bash
set -e

# Install utilities used by developers
# net-tools exists in 18.04, but is no longer in 20.04
utils_install() {
    sudo apt-get install htop -y
    sudo apt-get install openssl openssh-server -y
    sudo apt-get install mininet -y
    sudo apt-get install net-tools -y
    # make sure date is correct
    sudo apt-get install rdate -y
    # rdate command can timeout, restart script from here if this happens
    sudo rdate -n -4 time.nist.gov
    echo ">>>>> installed utils"
}

# Remove the software deployment and package management system called "Snap"
rm_snap_pkg() {
    sudo apt-get remove snapd -y
    sudo apt-get purge snapd -y
    echo ">>>>> snap package manager removed"
}

# Package needed for eclipse
java_func () {
    sudo apt-get install openjdk-11-jre-headless -y
    echo ">>>>> installed java"
}

# Create Eclipse shortcut
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

# Eclipse install
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

#MM TODO: need to test this function and add mininet install
graphing_installs() {
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] https://packages.grafana.com/oss/deb stable main"
    sudo apt-get update
    sudo apt-get install grafana
    # decided not to start the service automatically, it can be started using:  sudo /bin/systemctl start grafana-server
    echo ">>>>> installed grafana"

    #https://docs.influxdata.com/influxdb/v2.0/get-started
    wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.4-amd64.deb
    sudo dpkg -i influxdb2-2.0.4-amd64.deb
    echo ">>>>> installed influxdb2"

    #PREVIOUS_PWD=$PWD
    #git clone https://github.com/RIAPS/mininet.git /tmp/3rdparty/mininet
    #cd /tmp/3rdparty/mininet
    #git checkout 2.3.0
    #util/install.sh -fnv --setup.py install
    #cd $PREVIOUS_PWD
    #rm -rf /tmp/3rdparty/mininet
    #echo ">>>>> installed mininet"
}

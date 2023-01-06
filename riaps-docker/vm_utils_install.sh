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

graphing_installs() {
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo add-apt-repository -n "deb [arch=$HOST_ARCH] https://packages.grafana.com/oss/deb stable main"
    sudo apt-get update
    sudo apt-get install grafana
    # decided not to start the service automatically, it can be started using:  sudo /bin/systemctl start grafana-server
    echo ">>>>> installed grafana"

    #https://docs.influxdata.com/influxdb/v2.0/get-started
    wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.4.0-amd64.deb
    sudo dpkg -i influxdb2-2.4.0-amd64.deb
    echo ">>>>> installed influxdb2"

    #PREVIOUS_PWD=$PWD
    git clone https://github.com/RIAPS/mininet.git /tmp/3rdparty/mininet
    cd /tmp/3rdparty/mininet
    git checkout 2.3.0
    #sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    # Note: had issues with this script pulling openflow repo - best to run the rest of this section manually
    #       To fix, I downloaded the openflow repo to mininet/.. and commented out the clone (line 235)
    sudo $PYTHON=python3 util/install.sh -fnv
    sudo pip3 install 'pyflakes==2.2.0'
    cd $PREVIOUS_PWD
    rm -rf /tmp/3rdparty/mininet
    echo ">>>>> installed mininet"
}

nodered_install() {
    # install FlashMQ
    git clone https://github.com/halfgaar/FlashMQ.git
    cd FlashMQ/
    git checkout v0.11.8
    ./build.sh
    cd FlashMQBuildRelease/
    # This line will change with new releases 
    # MM TODO: note the filename seems to vary with build even given a set tag 
    sudo dpkg -i flashmq_0.11.3-1665529621+focal_amd64.deb

    # install MQTT
    sudo pip3 install paho-MQTT
    echo "allow_anonymous true" >> /etc/flashmq/flashmq.conf

    # install nodejs version (latest)
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install nodejs -y
    node -v
    npm -v

    # install nodered
    sudo npm install -g --unsafe-perm node-red
    npm i --package-lock-only
    npm audit fix
    
    # install node-red-dashboard
    sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/.node-red
    cd .node-red
    npm install node-red-dashboard
    npm install node-red-contrib-ui-svg
    npm list
}
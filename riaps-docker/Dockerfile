ARG CREATED=test
ARG REVISION=test

FROM ubuntu:20.04 as riaps-dev
ENV TZ=US/Central
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG RIAPS_VERSION="v1.1.20"
ENV RIAPS_VERSION=${RIAPS_VERSION}
ENV RIAPS_SETUP_HOME=/opt/riaps
ARG RIAPSUSER="riaps"

WORKDIR /opt

RUN apt-get update && apt-get install -q -y \
    autoconf \
    autogen \
    build-essential \
    byacc \
    cmake \
    flex \
    gcc-9 \
    g++-9 \
    libtool \
    libtool-bin \
    libreadline-dev

# Install Python / PIP
RUN apt-get update && apt-get install -q -y \
    python3-dev \
    python3-setuptools \
    python3-pip \
    python-is-python3

RUN pip3 install --upgrade pip

# Install utilities
RUN apt-get update && apt-get install -q -y \
    curl \
    git \
    htop \
    mininet \
    nano \
    net-tools \
    openssl \
    openssh-server \
    rdate \
    tmux \
    vim \
    wget
    
# rdate command can timeout, restart script from here if this happens
# MM TODO: this needs an interface to reach time.nist.gov, work later
#RUN rdate -n -4 time.nist.gov

# Remove the software deployment and package management system called "Snap"
RUN apt-get remove snapd -y
RUN apt-get purge snapd -y

# Hardwary Setups (vm_hw_setup.sh), including gpio
# timesync_requirements
RUN apt-get update && apt-get install -q -y \
    chrony \
    gpiod \
    gpsd \
    libffi-dev \
    libgpiod-dev \
    libiio-utils \
    libssl-dev \
    linuxptp \
    rng-tools
# MM TODO:  figure out why this does not run
#RUN systemctl start rng-tools.service

# watchdog_timers
RUN echo " " >> /etc/sysctl.conf
RUN echo "###################################################################" >> /etc/sysctl.conf
RUN echo "# Enable Watchdog Timer on Kernel Panic and Kernel Oops" >> /etc/sysctl.conf
RUN echo "# Enable OOM-Killer" >> /etc/sysctl.conf
RUN echo "# Added for RIAPS Platform (10/25/21, MM)" >> /etc/sysctl.conf
RUN echo "kernel.panic_on_oops = 1" >> /etc/sysctl.conf
RUN echo "kernel.panic = 5" >> /etc/sysctl.conf
RUN echo "vm.oom-kill = 1" >> /etc/sysctl.conf

# PIP installs
RUN pip3 install 'git+https://github.com/cython/cython.git@0.29.32'

# Install boost and nethogs pre-requisites
# Assumes libncurses6  is already installed
RUN apt-get update && apt-get install -q -y \
    libboost-dev \
    libpcap-dev \
    libncurses5-dev

# Install libraries for czmq and zyre
# Assumes libzmq5 is already installed
# For 20.04, pkg-config is already installed
RUN apt-get update && apt-get install -q -y \
    libcurl4-gnutls-dev \
    libsystemd-dev \
    libzmq3-dev \
    pkg-config

# Install apparmor, gnutls, msgpack and opendht prerequisties
# Assumes libgnutls30 is already installed
# For Ubuntu 20.04, python3-cryto and python3-keyrings.alt are not installed
# Assumes libncurses5-dev is install (done for nethogs above)
RUN apt-get update && apt-get install -q -y \
    apparmor-utils \
    libgnutls28-dev \
    libmsgpackc2 \
    libmsgpack-dev \
    libargon2-0-dev \
    libasio-dev \
    libfmt-dev \
    libhttp-parser-dev \
    libjsoncpp-dev \
    libncurses5-dev \
    nettle-dev 

    # run liblinks script to link gnutls and msgppack
    # MM TODO: not sure yet how to do a for loop here, may need to be a separate script
#    PREVIOUS_PWD=$PWD
#     chmod +x /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
#     for arch_tool in ${CROSS_TOOLCHAIN_LOC[@]}; do
#         cd /usr/lib/$arch_tool
#         sudo /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/liblinks.sh
#     done
#     cd $PREVIOUS_PWD

# Install redis
RUN wget http://download.redis.io/releases/redis-7.0.5.tar.gz
RUN tar xzf redis-7.0.5.tar.gz
RUN make -C redis-7.0.5 BUILD_TLS=yes
RUN make -C redis-7.0.5 install
RUN mkdir -p /etc/redis
RUN cp redis-7.0.5/redis.conf /etc/redis/.
RUN rm -rf redis-7.0.5
RUN rm -rf redis-7.0.5.tar.gz

# Install graphical elements used by the riaps_ctrl command
RUN apt-get update && apt-get install -q -y \
    graphviz \
    xdot

# Setup User Account
RUN useradd -m -c "RIAPS App Developer" $RIAPSUSER -s /bin/bash -d /home/$RIAPSUSER
#MM TODO RUN echo -e "riaps\nriaps" | passwd $RIAPSUSER
RUN usermod -aG sudo $RIAPSUSER
RUN mkdir -p /home/$RIAPSUSER/riaps_apps
RUN chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/riaps_apps

# Setup SSH keys on the VM and install scripts to allow setup later with remote RIAPS nodes
# RUN mkdir -p /home/$INSTALL_USER/.ssh
# RUN ssh-keygen -N "" -q -f $PRIVATE_KEY
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh
# RUN cp $PUBLIC_KEY /home/$RIAPSUSER/.ssh/id_rsa.pub
# RUN cp $PRIVATE_KEY /home/$RIAPSUSER/.ssh/id_rsa.key
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/id_rsa.pub
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/id_rsa.key
# RUN -H -u $RIAPSUSER cat /home/$RIAPSUSER/.ssh/id_rsa.pub >> /home/$RIAPSUSER/.ssh/authorized_keys
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.ssh/authorized_keys
# RUN -H -u $RIAPSUSER chmod 600 /home/$RIAPSUSER/.ssh/authorized_keys
# RUN -H -u $RIAPSUSER chmod 400 /home/$RIAPSUSER/.ssh/id_rsa.key
RUN echo "# RIAPS:  Add SSH keys to ssh agent on login" >> /home/$RIAPSUSER/.bashrc
RUN echo "ssh-add /home/$RIAPSUSER/.ssh/id_rsa.key" >> /home/$RIAPSUSER/.bashrc

# Setup RIAPS ssh keys for use with VM
# RUN cp -r riaps_initial_keys /home/$RIAPSUSER/.
# RUN chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/riaps_initial_keys
# RUN chmod 400 /home/$RIAPSUSER/riaps_initial_keys/riaps_initial.key
# RUN echo "ssh-add /home/$RIAPSUSER/riaps_initial_keys/riaps_initial.key" >> /home/$RIAPSUSER/.bashrc

# Transfer RIAPS rekeying script
# RUN cp secure_keys /home/$RIAPSUSER/.
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/secure_keys
# RUN chmod 700 /home/$RIAPSUSER/secure_keys

# Simple example project setup to allow users to quickly test the VM setup
# RUN mkdir -p /home/$RIAPSUSER/env_setup_tests/WeatherMonitor
# RUN cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/env_setup_tests/WeatherMonitor /home/$RIAPSUSER/env_setup_tests/
# RUN chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/env_setup_tests/WeatherMonitor

# Create a file that tracks the version installed on the VM, will help in debugging efforts
RUN mkdir -p /home/$RIAPSUSER/.riaps
RUN echo "RIAPS Version: $RIAPS_VERSION" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
RUN echo "Ubuntu Version: $UBUNTU_VERSION_INSTALL" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
RUN echo "Application Developer Username: $RIAPSUSER" >> /home/$RIAPSUSER/.riaps/riapsversion.txt
RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/.riaps/riapsversion.txt
RUN chmod 600 /home/$RIAPSUSER/.riaps/riapsversion.txt

# Add RIAPS User to the sudoer list
# RUN echo "$RIAPSUSER  ALL=(ALL) NOPASSWD: ALL" >> riaps
# RUN mv riaps /etc/sudoers.d/.
# RUN chmod 0440 /etc/sudoers.d/riaps

# Setup example project files from https://github.com/RIAPS/riaps-apps and appropriate eclipse launch files from https://github.com/RIAPS/riaps-pycom
RUN git clone https://github.com/RIAPS/riaps-apps.git
RUN mkdir -p /home/$RIAPSUSER/riaps_projects
# MM TODO: update to have files here
# RUN cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-apps/apps-vu/DistributedEstimator /home/$RIAPSUSER/riaps_projects/.
# RUN cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-apps/apps-vu/DistributedEstimatorGPIO /home/$RIAPSUSER/riaps_projects/.
# RUN cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-apps/apps-vu/WeatherMonitor /home/$RIAPSUSER/riaps_projects/.
RUN chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/riaps_projects
RUN chmod -R +w /home/$RIAPSUSER/riaps_projects

# # Add eclipse launch files to user files
# git clone https://github.com/RIAPS/riaps-pycom.git
# sudo -H -u $RIAPSUSER mkdir -p /home/$RIAPSUSER/riaps_launch_files
# sudo cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-pycom/bin/riaps_ctrl.launch /home/$RIAPSUSER/riaps_launch_files/.
# sudo cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-pycom/bin/riaps_deplo.launch /home/$RIAPSUSER/riaps_launch_files/.
# sudo cp -r /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps-pycom/bin/rpyc_registry.launch /home/$RIAPSUSER/riaps_launch_files/.
# sudo chown $RIAPSUSER:$RIAPSUSER -R /home/$RIAPSUSER/riaps_launch_files

# Setup RIAPS repository and install script
# Add RIAPS repository
RUN apt-get update && apt-get install -q -y \
    apt-transport-https \
    software-properties-common
RUN add-apt-repository -r "deb [arch=$HOST_ARCH] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main" || true
RUN add-apt-repository -n "deb [arch=$HOST_ARCH] https://riaps.isis.vanderbilt.edu/aptrepo/ $CURRENT_PACKAGE_REPO main"
RUN wget -qO - https://riaps.isis.vanderbilt.edu/keys/riapspublic.key | apt-key add -
# RUN apt-get update
# MM TODO: update this
# RUN cp /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/riaps_install_vm.sh /home/$RIAPSUSER/.
# RUN chown $RIAPSUSER:$RIAPSUSER /home/$RIAPSUSER/riaps_install_vm.sh
# RUN -H -u $RIAPSUSER chmod 711 /home/$RIAPSUSER/riaps_install_vm.sh
# RUN ./riaps_install_vm.sh

#EXPOSE 8182
#USER janusgraph

#ENTRYPOINT [ "/bin/bash", "/usr/local/bin/docker-entrypoint.sh" ]
#CMD [ "janusgraph" ]

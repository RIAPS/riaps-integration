#!/usr/bin/env bash
# Instructions for use, user should do the following:
# 1) git clone https://github.com/RIAPS/riaps-integration.git
# 2) cd riaps-integration/riaps-x86runtime
# 3) chmod +x riaps_update_vm_v1_1_18.sh
# 4) sudo ./riaps_update_vm_v1_1_18.sh 2>&1 | tee install_updated_vm.log
# 5) rm -rf riaps-integration
# 6) Reset the 'nic_name' in the /etc/riaps/riaps.conf file to be the same as the VM network
#    interface that is attached to the router servicing the remote RIAPS nodes

set -e

# Identify the host architecture
HOST_ARCH="$(dpkg --print-architecture)"
CURRENT_PACKAGE_REPO="$(lsb_release -sc | cut -d ' ' -f 2)"

# Available RIAPS Node Architecture Types for cross compiling (no harm in including both)
ARCHS_CROSS=("armhf" "arm64")

# Only need to indicate new architecture tool location here
CROSS_TOOLCHAIN_LOC=("aarch64-linux-gnu")

# Username of installer
INSTALL_USER="riaps"

source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`
    do
        source "$PWD/$SCRIPTS/$i"
    done
    echo ">>>>> sourced install scripts"
}

# make sure date is correct
sudo rdate -n -4 time.nist.gov

# make sure pip is up to date
sudo pip3 install --upgrade pip

# New packages installed/removed
source_scripts
rm_snap_pkg

# Add arm64 architecture to VM for development cross compiling
add_cross_compile_archs
sudo cat /etc/apt/sources.list
echo ">>>>> updated sources.list for multiarch"
sudo apt-get update
add_cross_compile_buildtools

# Setup calls that will add new architecture packages to VM
cmake_func
python_install
boost_install
nethogs_prereq_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
opendht_prereqs_install

# Externals_cmake_install
PREVIOUS_PWD=$PWD
externals_cmake_build ${ARCHS_CROSS[1]}
cd $PREVIOUS_PWD
echo ">>>>> completed external third party builds for ${ARCHS_CROSS[1]} architecture"

pip3_3rd_party_installs
prctl_install

# Removed reference to bbb to make generic for additional remote computing node types
mv /home/riaps/bbb_initial_keys /home/riaps/riaps_initial_keys
mv /home/riaps/riaps_initial_keys/bbb_initial.key /home/riaps/riaps_initial_keys/riaps_initial.key
mv /home/riaps/riaps_initial_keys/bbb_initial.pub /home/riaps/riaps_initial_keys/riaps_initial.pub
rm /home/riaps/secure_keys
rm /home/riaps/riaps_install_amd64.sh
cp /home/riaps/riaps-integration/riaps-x86runtime/secure_keys /home/riaps/.
cp /home/riaps/riaps-integration/riaps-x86runtime/riaps_install_vm.sh /home/riaps/.
chmod 700 /home/riaps/secure_keys
sudo chown riaps:riaps /home/riaps/secure_keys
chmod 711 /home/riaps/riaps_install_vm.sh
sudo chown riaps:riaps /home/riaps/riaps_install_vm.sh
echo ">>>>> Moved bbb reference to generic (riaps) for additional remote computing node types"

# For v1.1.18, riaps-pycom riaps.conf and riaps-log.conf files have been update
# it is best to remove the riaps-pycom-amd64 package completely and then reinstall
# Remember to update the nic name for /etc/riaps.conf after installation
sudo apt-get purge riaps-pycom-$HOST_ARCH || true

# install RIAPS packages
sudo apt-get update
sudo apt-get install riaps-core-$HOST_ARCH riaps-pycom-$HOST_ARCH riaps-timesync-$HOST_ARCH -y

echo "updated RIAPS platform to v1_1_18"

#!/usr/bin/env bash

# Packages already in base 18.04 image that are utilized by RIAPS Components:
# GCC 7, G++ 7, libpcap0.8, libnettle6, software-properties-common, libnss-mdns
# Python 3.6, libcurl4, libcurl3-gnutls, libncurses5, libzmq5, libgnutls30, firefox,
# libhogweed4, libgmp10, openssl (1.1.0g-2ubuntu4), snapd, net-tools
#
# Installed prior to this script: GIT, quota
#
# Need to remove: python3-crypto python3-keyrings.alt -y

# Script Variables
RIAPSAPPDEVELOPER=riaps


# Source scripts needed for this bootstrap build
source_scripts() {
    PWD=$(pwd)
    SCRIPTS="install_scripts"

    for i in `ls $PWD/$SCRIPTS`
    do
        source "$PWD/$SCRIPTS/$i"
    done
    echo ">>>>> sourced install scripts"
}

# Script functions

# User can supply ssh key pair, but must supply an intended name pair
parse_args()
{
    for ARGUMENT in "$@"
    do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)
        case "$KEY" in
            public_key)               PUBLIC_KEY=${VALUE} ;;
            private_key)              PRIVATE_KEY=${VALUE} ;;
            help)                     HELP="true" ;;
            *)
        esac
    done
    pwd
    if [ -e "$PUBLIC_KEY" ] && [ -e "$PRIVATE_KEY" ]
    then
        echo ">>>>> Found user ssh keys.  Will use them"
    else
        echo ">>>>> Did not find public_key=<name>.pub private_key=<name>.key. Generating it now."
        mkdir -p /home/riapsadmin/.ssh
        ssh-keygen -N "" -q -f $PRIVATE_KEY
    fi
}

print_help()
{
    if [ "$HELP" = "true" ]; then
        echo "usage: test_key_move [help] [=]"
        echo "arguments:"
        echo "help                       show this help message and exit"
        echo "public_key=<name>.pub      name of public key file"
        echo "private_key=<name>.key     name of private file"
        exit
    fi
}


# Start of script actions
set -e
mkdir -p /tmp/3rdparty
source_scripts
parse_args $@
print_help
user_func
setup_ssh_keys $RIAPSAPPDEVELOPER
rm_snap_pkg
cross_setup
vim_func
java_func
cmake_func
utils_install
timesync_requirements
python_install
cython_install
curl_func
boost_install
#eclipse_func $RIAPSAPPDEVELOPER - MM removed, done manually at this time
eclipse_plugin_dep_install
nethogs_prereq_install
zyre_czmq_prereq_install
gnutls_install
msgpack_install
security_prereq_install
opendht_prereqs_install
externals_cmake_install
pycapnp_install
pyzmq_install
czmq_pybindings_install
zyre_pybindings_install
apparmor_monkeys_install
redis_install
other_pip3_installs
spdlog_python_install
graphviz_install
prctl_install
rm -rf /tmp/3rdparty
add_set_tests $RIAPSAPPDEVELOPER
riaps_prereq $RIAPSAPPDEVELOPER

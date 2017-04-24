#!/usr/bin/env bash

# path
deb_location=$HOME/riaps-release
pycom_name="riaps-pycom"
core_name="riaps-core"
external_name="riaps-externals"

# functions sections
is_pkg_installed()
{
    pkg_status=`dpkg -s $1 | grep -c "ok installed"`
    if [ $pkg_status -gt 0 ];
    then
	return 1
    else
	return 0
    fi
}

uninstall_deb_pkg()
{
    is_pkg_installed $1
    status=$?
    if [ $status -eq 1 ];
    then
	echo "$1 is Installed. Removing package before installing new version."
	sudo dpkg -r $1
    else
	echo "$1 not installed"
    fi
}

install_deb_pkg()
{
    pkg_deb_path=$deb_location/$1.deb
    if [ ! -e $pkg_deb_path  ]; then
	echo "Unable to install $pkg_deb_path: file not found"    
    else
	echo "********** Installing $pkg_deb_path **********"
	sudo dpkg -i $pkg_deb_path
    fi
}

is_pip_pkg_installed()
{
    pkg_status=`pip3 list | grep -c -w "$1 "`;

    if [ $pkg_status -gt 0 ];
    then
	#echo "$1 is installed"
	return 1
    else
	return 0
    fi
}

uninstall_pip_pkg()
{
    is_pip_pkg_installed $1
    status=$?
    if [ $status -eq 1 ];
    then
	echo "uninstall_pip_pkg(): $1 python package installed"
	sudo pip3 uninstall -y $1
    else
	echo "uninstall_pip_pkg(): $1 python package not installed"
    fi
}

install_pip_pkg()
{
    pkg_name=$1.tar.gz
    if [ -e $pkg_path ];
    then
	cd $deb_location
	tar xzvf $pkg_name
	cd $1/src
	#echo `pwd`
	echo "++++++ install_pip_pkg(): Installing pip package $1"
	sudo pip3 install . --process-dependency-links
    fi
}


# parse command line
parse_args()
{
    for ARGUMENT in "$@"
    do
	KEY=$(echo $ARGUMENT | cut -f1 -d=)
	VALUE=$(echo $ARGUMENT | cut -f2 -d=)
	case "$KEY" in
	    release_dir)              RELEASE_PATH=${VALUE} ;;
	    arch)                     ARCH=${VALUE} ;;
	    help)                     HELP="true" ;;
	    *)
	esac
    done

    if [ "$RELEASE_PATH" = "" ]; then
	echo "Must pass in path to the release directory [release_dir='/some_path/dir_name']"
	exit
    fi
    
    if [ -d $RELEASE_PATH ]; then
	deb_location=$RELEASE_PATH
    else
	echo "Release directory [$release_dir] does not exist!"
	exit
    fi

    architecture=`echo $ARCH| tr '[:upper:]' '[:lower:]'`
    if [ "$architecture" != "armhf" ] && [ "$architecture" != "amd64" ]; then
	echo "Passed in architecture: arch=$architecture."
	echo "Installation can not proceed, architurecture must be arch=amd64 or arch=armhf"
	exit	
    fi

    pycom_name=`echo "$pycom_name-$architecture"`
    core_name=`echo $core_name-$architecture`
    external_name=`echo $external_name-$architecture`
}

print_help()
{
    if [ "$HELP" = "true" ]; then
	echo "usage: install_integration [help] [=]"
	echo "arguments:"
	echo "help     				show this help message and exit"
	echo "arch=amd64 or armhf		architecture version amd64 or armhf"
	echo "release_dir=/dir_path             directory that contains deb files"
	exit
    fi
}

parse_args $@
print_help

# uninstall section
uninstall_deb_pkg $core_name
uninstall_deb_pkg $external_name
uninstall_deb_pkg $pycom_name


disco_link=/usr/local/bin/riaps_disco
redis_disco=/usr/local/bin/riaps_disco_redis

if [ -e $redis_disco ];
then
    echo "removing $redis_disco"
    sudo rm $redis_disco
fi

if [ -L $disco_link ];
then
    echo "removing $disco_link"
    sudo rm $disco_link
fi


#uninstall_pip_pkg riaps-ts


# install section
install_deb_pkg $external_name
install_deb_pkg $core_name
install_deb_pkg $pycom_name


# create symbolic link for pycom disco
cpp_disco=/opt/riaps/armhf/bin/rdiscoveryd
if [ -e $disco_link ] && [ -e $cpp_disco ];
then
    sudo cp $disco_link $redis_disco
    sudo rm $disco_link
    sudo ln -s $cpp_disco $disco_link
fi

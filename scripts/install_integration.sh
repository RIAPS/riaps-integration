#!/usr/bin/env bash

# path
deb_location=$HOME/riaps-release
pycom_name="riaps-pycom"
core_name="riaps-core"
external_name="riaps-externals"
disco_link=/usr/local/bin/riaps_disco
redis_disco=/usr/local/bin/riaps_disco_redis


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
    echo "`date -u`"
	echo "=============== $1 is Installed. Removing package. ================"
	sudo dpkg -r $1
    #else
	#echo "============= $1 not installed =============="
    fi

    still_installed=`dpkg -l|grep $1|wc -l`
    if [ $still_installed -gt 0 ]; then
	echo "=============== $1 uninstall left config files. Purging package. ================"
	sudo dpkg -P $1
    fi
}

install_deb_pkg()
{
    pkg_deb_path=$deb_location/$1.deb
    if [ ! -e $pkg_deb_path  ]; then
	echo "Unable to install $pkg_deb_path: file not found"    
    else
    echo "`date -u`"
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
    echo "`date -u`"
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
	echo "`date -u`"
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
	    exclude_pycom)	      EXCLUDE_PYCOM="true" ;;
	    pkg)		      PKG=${VALUE} ;;
	    action)		      ACTION=${VALUE} ;;
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

    pkg_option=`echo $PKG| tr '[:upper:]' '[:lower:]'`
    if [ "$PKG" = "" ]; then
	pkg_option="all"
    fi
    if [ "$pkg_option" != "all" ] && [ "$pkg_option" != "externals" ] && [ "$pkg_option" != "pycom" ] && [ "$pkg_option" != "core" ] ; then
        echo "Passed in package: pkg=$pkg_option."
        echo "Installation can not proceed, pkg must be pkg=all|externals|pycom"
        exit
    fi

    if [ "$ACTION" = ""  ]; then
	ACTION="install"
    else
	if [ "$ACTION" != "install" ] && [ "$ACTION" != "uninstall" ]; then
		echo "Argument spelling error: action=install or action=uninstall."
		exit
	fi
    fi

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

remove_core_symlink()
{
    if [ -L $disco_link ];
    then
    	echo "removing $disco_link"
    	sudo rm $disco_link
    fi
}

create_core_symlink()
{
    # create symbolic link for pycom disco
    if [ -e $cpp_disco ]; then
    	sudo ln -s $cpp_disco $disco_link
    else
	echo "$cpp_disco does not exist, can not create symlink for riaps-core!"
    fi
}

uninstall_core()
{
    uninstall_deb_pkg $core_name
}

install_core()
{
    is_pkg_installed $external_name
    status=$?
    if [ $status -eq 1 ];
    then
        install_deb_pkg $core_name
    else
        echo "riaps-externals must be installed first before you can uninstall riaps-externals!"
    fi
}

uninstall_pycom()
{
    if [ "$EXCLUDE_PYCOM" = "false" ]; then
    	uninstall_deb_pkg $pycom_name
	if [ -e $redis_disco ]; then
		sudo rm $redis_disco
	fi
    fi
}

install_pycom()
{
    if [ "$EXCLUDE_PYCOM" = "false" ]; then
	install_deb_pkg $pycom_name
	if [ -e $disco_link ]; then
		sudo cp $disco_link $redis_disco
		sudo rm $disco_link
	fi
    fi
}

uninstall_externals()
{
    is_pkg_installed $core_name
    status=$?
    if [ $status -eq 1 ];
    then
	echo "riaps-core must be uninstall first before you can uninstall riaps-externals!"
    else
    	uninstall_deb_pkg $external_name
    fi
}

install_externals()
{
    install_deb_pkg $external_name
}

install_riaps_packages()
{
    if [ "$pkg_option" = "all" ]; then
	install_externals
	install_core
	install_pycom
	create_core_symlink
    elif [ "$pkg_option" = "pycom" ]; then
        install_pycom
    elif [ "$pkg_option" = "externals" ]; then
	install_externals
    elif [ "$pkg_option" = "core" ]; then
	install_core
    fi
}

uninstall_riaps_packages()
{
    if [ "$pkg_option" = "all" ]; then
        uninstall_core
        uninstall_externals
        uninstall_pycom
	remove_core_symlink
    elif [ "$pkg_option" = "pycom" ]; then
        uninstall_pycom
    elif [ "$pkg_option" = "externals" ]; then
        uninstall_externals
    elif [ "$pkg_option" = "core" ]; then
        uninstall_core
    fi

}


EXCLUDE_PYCOM="false"
parse_args $@
print_help
cpp_disco=/opt/riaps/$architecture/bin/rdiscoveryd


if [ "$ACTION" = "uninstall" ]; then
	uninstall_riaps_packages
elif [ "$ACTION" = "install" ]; then
	uninstall_riaps_packages
	install_riaps_packages
fi



echo "`date -u`"
echo "RIAPS Install is complete"

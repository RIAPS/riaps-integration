#!/bin/sh

# path
deb_location=./riaps-release
pycom_name="riaps-pycom"
core_name="riapscore-armhf"
external_name="riaps-externals-armhf"


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
	echo "********** Installing $pkg_deb_path **********"
	sudo dpkg -i $pkg_deb_path
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


# uninstall section
uninstall_deb_pkg $core_name
uninstall_deb_pkg $external_name


disco_link=/usr/local/bin/riaps_disco
redis_disco=/usr/local/bin/riaps_disco_redis
uninstall_pip_pkg riaps
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
install_pip_pkg $pycom_name


# create symbolic link for pycom disco
cpp_disco=/opt/riaps/armhf/bin/rdiscoveryd
if [ -e $disco_link ] && [ -e $cpp_disco ];
then
	sudo cp $disco_link $redis_disco
	sudo rm $disco_link
	sudo ln -s $cpp_disco $disco_link
fi

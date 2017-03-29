#!/bin/sh

# path
deb_location=/home/riaps/riaps-release

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
		echo "++++++ install_pip_pkg(): installing pip package $1"
		sudo pip3 install . --process-dependency-links
	fi

}


# uninstall section
uninstall_deb_pkg riapscore-armhf
uninstall_deb_pkg riaps-externals-armhf

pycom_name="riaps-pycom"
uninstall_pip_pkg riaps
if [ -e /usr/local/bin/riaps_disco_redis ];
then
       sudo rm /usr/local/bin/riaps_disco_redis
fi

#uninstall_pip_pkg riaps-ts


# install section
install_deb_pkg riaps-externals-armhf
install_deb_pkg riaps_core_armhf
install_pip_pkg $pycom_name


# create symbolic link for pycom disco
disco_link=/usr/local/bin/riaps_disco
redis_disco=/usr/local/bin/riaps_disco_redis
cpp_disco=/opt/riaps/armhf/bin/rdiscoveryd
if [ -e $disco_link ] && [ -e $cpp_disco ];
then
	sudo cp $disco_link $redis_disco
	sudo rm $disco_link
	sudo ln -s $cpp_disco $disco_link
fi

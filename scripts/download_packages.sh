#!/usr/bin/env bash

# Assumptions: Calling script has already sourced version.sh

# command line arg parsing
for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            pycom)              PYCOM_VER=${VALUE} ;;
            external)           EXTERNAL_VER=${VALUE} ;;
	    core)               CORE_VER=${VALUE} ;;
	    arch)		ARCH=${VALUE} ;;
	    version_conf)	VERSION=${VALUE} ;;
	    setup_conf)		SETUP=${VALUE} ;;
	    help)               HELP="true" ;;
            *)   
    esac    
done

# variable declarations
RELEASE_DIR=riaps-release
INTG_DIR=riaps-integration
RELEASE_ARTIFACT=$RELEASE_DIR.tar.gz

# functions
setup()
{
	if [ -d $RELEASE_DIR ]; then
		rm -rf $RELEASE_DIR/*
	else
		mkdir $RELEASE_DIR
	fi

	#if [ -d $INTG_DIR ]; then
	#	rm -rf $INTG_DIR
	#fi

	if [ -e $RELEASE_ARTIFACT ]; then
		rm $RELEASE_ARTIFACT
	fi
}

init_env()
{
	if [ "$GITHUB_OAUTH_TOKEN" = "" ]; then
		if [ "$SETUP" = "" ]; then
			echo "Need to pass in setup.conf file using setup_conf='/some_dir/setup.conf'"
			echo "Alternatively export GITHUB_OAUTH_TOKEN=blah_token before executing this script."
			exit
		else
			if [ -e $SETUP ]; then
				source $SETUP
			fi
			
			if [ -f $GITHUB_OAUTH_TOKEN ]; then
				export GITHUB_OAUTH_TOKEN=`less $GITHUB_OAUTH_TOKEN`	    
				
				if [ "$GITHUB_OAUTH_TOKEN" = "" ] ; then
				echo "Problem setting Github OAuth token."
				exit
				fi
			fi
		fi
	fi
	
	if [ "$VERSION" = "" ]; then
		echo "Need to pass in version.sh file using version_conf='/some_dir/version.sh'"
		exit
	else
		if [ -e $VERSION ]; then
			source $VERSION
		fi	
	fi	

}

set_repo_versions()
{
	if [ "$PYCOM_VER" != "" ]; then
			export pycomversion=$PYCOM_VER
	fi

	if [ "$CORE_VER" != "" ]; then
			export coreversion=$CORE_VER
	fi

	if [ "$EXTERNAL_VER" != "" ]; then
			export externalsversion=$EXTERNAL_VER
	fi

	architecture="all"
	expected_file_count=0
	if [ "$ARCH" != "" ]; then
		architecture=`echo $ARCH| tr '[:upper:]' '[:lower:]'`
	fi
}

print_help()
{
    if [ "$HELP" = "true" ]; then
	echo "usage: download_packages [help] [=]"
	echo "arguments:"
	echo "help     				show this help message and exit"
	echo "pycom=0.0.0			pycom release version, default from version.h"
	echo "external=0.0.0			external release version, default from version.h"
	echo "core=0.0.0			core release version, default from version.h"
	echo "arch=amd64 or armhf		architecture version amd64 or armhf"
	echo "version_conf=/path/version.sh"
	echo "setup_conf=/path/setup.conf"
	exit
    fi
}

# start of steps
print_help
setup
init_env
set_repo_versions


if [ ! -e "fetch_linux_amd64"  ]; then
	wget https://github.com/gruntwork-io/fetch/releases/download/v0.1.1/fetch_linux_amd64
	chmod +x fetch_linux_amd64
fi


echo "Fetching ========> pycom = $pycomversion, external = $externalsversion, core = $coreversion, architecture = $architecture <========"


# fetch repos based on version number
if [ "$architecture" = "all" ] || [ "$architecture" = "amd64" ]; then
expected_file_count=`expr $expected_file_count + 3`
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals" --tag="$externalsversion" --release-asset="riaps-externals-amd64.deb" ./$RELEASE_DIR
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag="$coreversion" --release-asset="riaps-core-amd64.deb" ./$RELEASE_DIR
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag="$pycomversion" --release-asset="riaps-pycom-amd64.deb" ./$RELEASE_DIR
fi

if [ "$architecture" = "all" ] || [ "$architecture" = "armhf" ]; then
expected_file_count=`expr $expected_file_count + 3`
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals" --tag="$externalsversion" --release-asset="riaps-externals-armhf.deb" ./$RELEASE_DIR
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag="$coreversion" --release-asset="riaps-core-armhf.deb" ./$RELEASE_DIR
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag="$pycomversion" --release-asset="riaps-pycom-armhf.deb" ./$RELEASE_DIR
fi


downloaded_file_count=`find ./$RELEASE_DIR -name *.deb | wc -l`
if [ $downloaded_file_count -eq $expected_file_count ]; then
	tar czvf $RELEASE_ARTIFACT ./$RELEASE_DIR
else
	echo "Not all release deb files got downloaded! Expected $expected_file_count, got $downloaded_file_count."
fi









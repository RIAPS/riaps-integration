#!/bin/sh

# check for oauth
if [ "$GITHUB_OAUTH_TOKEN" = "" ] ; then
    echo "Github OAuth token not set."
    exit
fi

# command line arg parsing
for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            pycom)              PYCOM_VER=${VALUE} ;;
            external)           EXTERNAL_VER=${VALUE} ;;
	    core)               CORE_VER=${VALUE} ;;
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

	if [ -d $INTG_DIR ]; then
		rm -rf $INTG_DIR
	fi

	if [ -e $RELEASE_ARTIFACT ]; then
		rm $RELEASE_ARTIFACT
	fi
}


setup

if [ ! -e "fetch_linux_amd64"  ]; then
	wget https://github.com/gruntwork-io/fetch/releases/download/v0.1.1/fetch_linux_amd64
	chmod +x fetch_linux_amd64
fi

./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-integration" --branch="master" ./riaps-integration
chmod +x $INTG_DIR/version.sh
. $INTG_DIR/version.sh

if [ "$PYCOM_VER" != "" ]; then
		export pycomversion=$PYCOM_VER
fi

if [ "$CORE_VER" != "" ]; then
		export coreversion=$CORE_VER
fi

if [ "$EXTERNAL_VER" != "" ]; then
		export externalsversion=$EXTERNAL_VER
fi

echo "Fetching ========> pycom = $pycomversion, external = $externalsversion, core = $coreversion <========"


# fetch repos based on version number
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals" --tag="$externalsversion" --release-asset="riaps-externals-armhf.deb" ./riaps-release
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-externals" --tag="$externalsversion" --release-asset="riaps-externals-amd64.deb" ./riaps-release

./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag="$coreversion" --release-asset="riaps-core-armhf.deb" ./riaps-release
./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-core" --tag="$coreversion" --release-asset="riaps-core-amd64.deb" ./riaps-release

./fetch_linux_amd64 --repo="https://github.com/RIAPS/riaps-pycom" --tag="$pycomversion" --release-asset="riaps-pycom-armhf.deb" ./riaps-release


tar czvf $RELEASE_ARTIFACT ./$RELEASE_DIR









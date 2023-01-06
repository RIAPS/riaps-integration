# Install external packages using cmake
# libraries installed: capnproto, lmdb, libnethogs, CZMQ, Zyre, opendht, libsoc
externals_cmake_install(){
    PREVIOUS_PWD=$PWD

    # Host architecture
    externals_cmake_build $HOST_ARCH
    cd $PREVIOUS_PWD
    echo ">>>>> cmake install complete"
}


externals_cmake_build(){
    mkdir -p /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cd /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
    cmake -Darch=$1 ..
    make
    cd /home/$INSTALL_USER$INSTALL_SCRIPT_LOC
    rm -rf /home/$INSTALL_USER$INSTALL_SCRIPT_LOC/build-$1
}

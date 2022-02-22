#!/usr/bin/env bash
set -e

# Note that using CMake with qemu for an arm 32 processor is a known issue
# (https://gitlab.kitware.com/cmake/cmake/-/issues/20568). So doing individual builds
build_external_libraries() {
    build_capnproto
    build_lmdb
    build_nethogs
    build_czmq
    build_zyre
    build_opendht
    if [ "$NODE_ARCH" = "armhf" ]; then
        build_libsoc
    fi
    sudo ldconfig
    echo ">>>>> built all external libraries"
}

#Capnproto
build_capnproto() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/capnproto/capnproto $TMP/capnproto
    cd $TMP/capnproto
    git checkout v0.8.0
    autoreconf -i c++
    cd c++ && ./configure --enable-shared
    cd ..
    make -j2 -C c++
    sudo make -C c++ install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built capnproto library"
}

# LMDB
build_lmdb() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/LMDB/lmdb.git $TMP/lmdb
    cd $TMP/lmdb
    git checkout LMDB_0.9.28
    make -j2 -C ./libraries/liblmdb
    sudo make -C ./libraries/liblmdb install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built lmdb library"
}

# libnethogs
build_nethogs() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/raboof/nethogs $TMP/nethogs
    cd $TMP/nethogs
    git checkout v0.8.6
    make -j2 libnethogs
    sudo make -j2 install_dev
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built nethogs library"
}

# High-level C binding for ØMQ
build_czmq() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq
    cd $TMP/czmq
    git checkout v4.2.1
    ./autogen.sh
    ./configure --enable-drafts --with-uuid=no --with-libsystemd=no --with-liblz4=no --enable-zmakecert=no --enable-zsp=no --enable-test_randof=no --enable-czmq_selftest=no
    make -j2
    sudo make install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built czmq library"
}

# Zyre
build_zyre() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre
    cd $TMP/zyre
    git checkout v2.0.1
    ./autogen.sh
    ./configure --enable-drafts
    make -j2
    sudo make install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built zyre library"
}

# OpenDHT
build_opendht() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/savoirfairelinux/opendht.git $TMP/opendht
    cd $TMP/opendht
    git checkout 2.1.10
    ./autogen.sh
    ./configure PKG_CONFIG_PATH=/usr/local/lib/pkgconfig MsgPack_LIBS="-L/usr/lib/$ARCHINSTALL -lmsgpackc" MsgPack_CFLAGS=-I/usr/include/$ARCHINSTALL CFLAGS=-I/tmp/3rdparty/opendht/argon2/include
    #Nettle_LIBS="-L/usr/lib/$ARCHINSTALL -lnettle" Nettle_CFLAGS=-I/usr/include/$ARCHINSTALL GnuTLS_LIBS="-L/usr/lib/$ARCHINSTALL -lgnutls" GnuTLS_CFLAGS=-I/usr/include/$ARCHINSTALL
    make -j2
    sudo make install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built opendht library"
}

# libsoc
build_libsoc() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jackmitch/libsoc.git $TMP/libsoc
    cd $TMP/libsoc
    git checkout 379f909690ea776cb6592bf246cce819b9da0ebd
    autoreconf -i
    ./configure --enable-board=beaglebone_black
    make -j2
    sudo make install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built libsoc library"
}

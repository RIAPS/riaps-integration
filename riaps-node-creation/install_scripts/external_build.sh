#!/usr/bin/env bash
set -e

# Note that using CMake with qemu for an arm 32 processor is a known issue
# (https://gitlab.kitware.com/cmake/cmake/-/issues/20568). So doing individual builds
build_external_libraries() {
    build_capnproto
    build_lmdb
    build_nethogs
    build_libzmq
    build_czmq
    build_zyre
    build_opendht
    if [ "$NODE_ARCH" = "armhf" ]; then
        build_libsoc
    fi
    configure_library_path
    echo ">>>>> built all external libraries"
}

configure_library_path() {
    sudo touch /etc/ld.so.conf.d/riaps.conf
    sudo echo "# Add RIAPS Library for ZeroMQ specific builds" >> /etc/ld.so.conf.d/riaps.conf
    sudo echo "$RIAPS_PREFIX/lib" >> /etc/ld.so.conf.d/riaps.conf
    sudo ldconfig
}

#Capnproto
build_capnproto() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/capnproto/capnproto $TMP/capnproto
    cd $TMP/capnproto
    git checkout v0.8.0
    start=`date +%s`
    autoreconf -i c++
    cd c++ && ./configure --enable-shared
    cd ..
    make -j2 -C c++
    sudo make -C c++ install
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    end=`date +%s`
    echo ">>>>> built capnproto library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# LMDB
build_lmdb() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/LMDB/lmdb.git $TMP/lmdb
    cd $TMP/lmdb
    git checkout LMDB_0.9.29
    start=`date +%s`
    make -j2 -C ./libraries/liblmdb
    sudo make -C ./libraries/liblmdb install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built lmdb library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# libnethogs
build_nethogs() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/raboof/nethogs $TMP/nethogs
    cd $TMP/nethogs
    git checkout v0.8.6
    start=`date +%s`
    make -j2 libnethogs
    sudo make -j2 install_dev
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built nethogs library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# libzmq with Draft APIs
build_libzmq() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/libzmq.git $TMP/libzmq
    cd $TMP/libzmq
    git checkout v4.3.2
    start=`date +%s`
    ./autogen.sh
    ./configure --prefix=$RIAPS_PREFIX --enable-drafts
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built libzmq library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# High-level C binding for ØMQ
build_czmq() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq
    cd $TMP/czmq
    git checkout v4.2.1
    start=`date +%s`
    ./autogen.sh
    ./configure --with-uuid=no --with-libsystemd=no --with-liblz4=no --enable-zmakecert=no --enable-zsp=no --enable-test_randof=no --enable-czmq_selftest=no --prefix=$RIAPS_PREFIX libzmq_LIBS="-L$RIAPS_PREFIX/lib -lzmq" libzmq_CFLAGS=-I$RIAPS_PREFIX/include
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built czmq library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# Zyre
build_zyre() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/zyre.git $TMP/zyre
    cd $TMP/zyre
    git checkout v2.0.1
    start=`date +%s`
    ./autogen.sh
    ./configure --prefix=$RIAPS_PREFIX libzmq_LIBS="-L$RIAPS_PREFIX/lib -lzmq" libzmq_CFLAGS=-I$RIAPS_PREFIX/include czmq_LIBS="-L$RIAPS_PREFIX/lib -lczmq" czmq_CFLAGS=-I$RIAPS_PREFIX/include
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built zyre library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# OpenDHT
build_opendht() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/savoirfairelinux/opendht.git $TMP/opendht
    cd $TMP/opendht
    git checkout v2.4.10
    start=`date +%s`
    ./autogen.sh
    ./configure 
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built opendht library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

# libsoc
build_libsoc() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/jackmitch/libsoc.git $TMP/libsoc
    cd $TMP/libsoc
    git checkout 379f909690ea776cb6592bf246cce819b9da0ebd
    start=`date +%s`
    autoreconf -i
    ./configure --enable-board=beaglebone_black
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built libsoc library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}

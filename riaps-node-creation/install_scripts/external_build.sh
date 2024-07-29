#!/usr/bin/env bash
set -e

# Note that using CMake with qemu for an arm 32 processor is a known issue
# (https://gitlab.kitware.com/cmake/cmake/-/issues/20568). So doing individual builds
build_external_libraries() {
    build_capnproto
    build_lmdb
    build_fmt
    build_nethogs
    build_czmq
    build_zyre
    build_opendht
    if [ "$NODE_ARCH" = "armhf" ]; then
        build_libsoc
    fi
    build_libply
    sudo ldconfig
    echo ">>>>> built all external libraries"
}

#Capnproto
build_capnproto() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/capnproto/capnproto $TMP/capnproto
    cd $TMP/capnproto
    git checkout v1.0.1.1
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
    git checkout LMDB_0.9.31
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

# LIBFMT
build_fmt() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/fmtlib/fmt.git $TMP/fmt
    cd $TMP/fmt
    git checkout 10.1.1
    mkdir $TMP/fmt/build
    cd build
    start=`date +%s`
    cmake -DBUILD_SHARED_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=/usr/local ..
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built fmt library"
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

# High-level C binding for ØMQ
build_czmq() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/zeromq/czmq.git $TMP/czmq
    cd $TMP/czmq
    git checkout v4.2.1
    start=`date +%s`
    ./autogen.sh
    ./configure --enable-drafts=yes
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
    ./configure --enable-drafts=yes
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
# Note: when building in a virtual environment, do the python install separately
build_opendht() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/savoirfairelinux/opendht.git $TMP/opendht
    cd $TMP/opendht
    git checkout v3.1.6
    start=`date +%s`
    ./autogen.sh
    ./configure --prefix=/usr/local
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

# libply
build_libply() {
    PREVIOUS_PWD=$PWD
    TMP=`mktemp -d`
    git clone https://github.com/wkz/ply.git $TMP/libply
    cd $TMP/libply
    git checkout 2.3.0
    start=`date +%s`
    ./autogen.sh 
    ./configure 
    make -j2
    sudo make install
    end=`date +%s`
    cd $PREVIOUS_PWD
    sudo rm -rf $TMP
    echo ">>>>> built libply library"
    diff=`expr $end - $start`
    echo ">>>>> Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
}
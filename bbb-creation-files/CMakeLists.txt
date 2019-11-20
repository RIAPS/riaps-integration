cmake_minimum_required(VERSION 3.0.0)
include(ExternalProject)
project(riaps-thirdpartypkgs)
include(ProcessorCount)

processorcount(N)
if(NOT N EQUAL 0)
  set(MAKE_JOB_FLAGS -j${N})
  message("${N} cpu found")
endif()

set(major 0 CACHE INTEGER "the major version")
set(minor 5 CACHE INTEGER "the minor version")

set(prefix /usr/local)
set(CMAKE_INSTALL_PREFIX ${prefix})

set(CMAKE_C_COMPILER gcc-7)
set(CMAKE_CXX_COMPILER g++-7)
set (CMAKE_C_FLAGS "-std=c99")

#Capnproto
externalproject_add(capnproto
                      GIT_REPOSITORY
                      "https://github.com/capnproto/capnproto"
                      GIT_TAG
                      "v0.6.1"
                      SOURCE_DIR
                      "/tmp/3rdparty/capnproto"
                      BUILD_IN_SOURCE
                      1
                      UPDATE_COMMAND
                      autoreconf
                      -i
                      c++
                      CONFIGURE_COMMAND
                      cd
                      c++
                      &&
                      ./configure
                      --enable-shared
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -C
                      c++
                      INSTALL_COMMAND
                      sudo make
                      -C
                      c++
                      install)


# LMDB
externalproject_add(liblmdb
                      GIT_REPOSITORY
                      "https://github.com/LMDB/lmdb.git"
                      GIT_TAG
                      "LMDB_0.9.24"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/liblmdb"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -C
                      ./libraries/liblmdb
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -C
                      ./libraries/liblmdb
                      install)


# libnethogs
externalproject_add(libnethogs
                      GIT_REPOSITORY
                      "https://github.com/raboof/nethogs"
                      GIT_TAG
                      "dbbee09d7939bf8efacdc90aa6c738f46e939f41"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/libnethogs"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      libnethogs
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      install_dev)


# High-level C binding for ØMQ
externalproject_add(czmq
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/zeromq/czmq.git"
                     GIT_TAG
                     "9ee60b18e8bd8ed4adca7fdaff3e700741da706e"
                     SOURCE_DIR
                     "/tmp/3rdparty/czmq"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --with-uuid=no
                     --with-libsystemd=no
                     --with-liblz4=no
                     --enable-zmakecert=no
                     --enable-zsp=no
                     --enable-test_randof=no
                     --enable-czmq_selftest=no
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)


# Zyre
externalproject_add(zyre
                     DEPENDS
                     czmq
                     GIT_REPOSITORY
                     "https://github.com/zeromq/zyre.git"
                     GIT_TAG
                     "b36470e70771a329583f9cf73598898b8ee05d14"
                     SOURCE_DIR
                     "/tmp/3rdparty/zyre"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)


# OpenDHT
 externalproject_add(opendht
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/savoirfairelinux/opendht.git"
                     GIT_TAG
                     "1.7.4"
                     SOURCE_DIR
                     "/tmp/3rdparty/opendht"
                     BUILD_IN_SOURCE
                     1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     PKG_CONFIG_PATH=${prefix}/pkgconfig
                     --disable-tools
                     --disable-python
                     --enable-indexation
                     #GnuTLS_LIBS="-L/usr/lib/arm-linux-gnueabihf -lgnutls"
                     #GnuTLS_CFLAGS=-I/usr/include/arm-linux-gnueabihf
                     MsgPack_LIBS="-L/usr/lib/arm-linux-gnueabihf -lmsgpackc"
                     MsgPack_CFLAGS=-I/usr/include/arm-linux-gnueabihf
                     CFLAGS=-I/tmp/3rdparty/opendht/argon2/include
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)


#libsoc
externalproject_add(libsoc
                      GIT_REPOSITORY
                      "https://github.com/jackmitch/libsoc.git"
                      GIT_TAG
                      "379f909690ea776cb6592bf246cce819b9da0ebd"
                      SOURCE_DIR
                      "/tmp/3rdparty/libsoc"
                      BUILD_IN_SOURCE
                      1
                      UPDATE_COMMAND
                      autoreconf
                      -i
                      CONFIGURE_COMMAND
                      ./configure
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      INSTALL_COMMAND
                      sudo make
                      install)

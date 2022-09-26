#Compiling on BBB (armhf), RPi (arm64) and Jetson Nano (arm64)
cmake_minimum_required(VERSION 3.16.0)
include(ExternalProject)
project(riaps-thirdpartypkgs)
include(ProcessorCount)
option(arch "armhf/arm64" "armhf")

processorcount(N)
if(NOT N EQUAL 0)
  set(MAKE_JOB_FLAGS -j${N})
  message("${N} cpu found")
endif()

set(major 0 CACHE INTEGER "the major version")
set(minor 5 CACHE INTEGER "the minor version")

set(prefix /usr/local)
set(CMAKE_INSTALL_PREFIX ${prefix})

if (${arch} STREQUAL "armhf")
  set(TOOLCHAIN_PREFIX arm-linux-gnueabihf)
elseif (${arch} STREQUAL "arm64")
  set(TOOLCHAIN_PREFIX aarch64-linux-gnu)
endif()

set(CMAKE_C_COMPILER gcc-9)
set(CMAKE_CXX_COMPILER g++-9)
set(CMAKE_C_FLAGS "-std=c99")

#Capnproto
externalproject_add(capnproto
                      GIT_REPOSITORY
                      "https://github.com/capnproto/capnproto"
                      GIT_TAG
                      "v0.8.0"
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
                      "LMDB_0.9.29"
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
                      "v0.8.6"
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
                     "v4.2.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/czmq"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --enable-drafts
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
                     "v2.0.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/zyre"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --enable-drafts
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
                     "v2.4.10"
                     SOURCE_DIR
                     "/tmp/3rdparty/opendht"
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


#libsoc - does not have a board configuration for RPi (so not built)
if(${arch} STREQUAL "armhf")
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
                      --enable-board=beaglebone_black
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      INSTALL_COMMAND
                      sudo make
                      install)
endif()

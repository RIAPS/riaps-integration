cmake_minimum_required(VERSION 3.0.0)
include(ExternalProject)
project(riaps-thirdpartypkgs)
option(arch "amd64/armhf/arm64" "amd64")
include(ProcessorCount)

processorcount(N)
if(NOT N EQUAL 0)
  set(MAKE_JOB_FLAGS -j${N})
  message("${N} cpu found")
endif()


set(major 0 CACHE INTEGER "the major version")
set(minor 5 CACHE INTEGER "the minor version")


if (${arch} STREQUAL "armhf")
 set(prefix /usr/arm-linux-gnueabihf)
elseif(${arch} STREQUAL "arm64")
 set(prefix /usr/aarch64-linux-gnu)
else()
 set(prefix /usr/local)
endif()
set(CMAKE_INSTALL_PREFIX ${prefix})

#Set the platform
if (${arch} STREQUAL "armhf")
 set(TOOLCHAIN_PREFIX /usr/bin/arm-linux-gnueabihf)
 set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
 set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++-9)
 set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX})
 set (CMAKE_C_FLAGS "-std=c99")
elseif(${arch} STREQUAL "arm64")
 set(TOOLCHAIN_PREFIX /usr/bin/aarch64-linux-gnu)
 set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
 set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++-9)
 set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX})
 set (CMAKE_C_FLAGS "-std=c99")
else()
 set(CMAKE_C_COMPILER gcc-9)
 set(CMAKE_CXX_COMPILER g++-9)
 set (CMAKE_C_FLAGS "-std=c99")
endif()

#Capnproto

if(${arch} STREQUAL "amd64")
 externalproject_add(capnproto-${arch}
                    GIT_REPOSITORY
                    "https://github.com/capnproto/capnproto"
                    GIT_TAG
                    "v0.8.0"
                    SOURCE_DIR
                    "/tmp/3rdparty/capnproto-${arch}"
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
elseif(${arch} STREQUAL "armhf")
 externalproject_add(capnproto-${arch}
                      #DEPENDS
                      #capnproto-amd64
                      GIT_REPOSITORY
                      "https://github.com/capnproto/capnproto"
                      GIT_TAG
                      "v0.8.0"
                      SOURCE_DIR
                      "/tmp/3rdparty/capnproto-${arch}"
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
                      --prefix=${prefix}
                      --host=arm-linux-gnueabihf
                      --target=arm-linux-gnueabihf
                      --enable-shared
                      --with-external-capnp
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
elseif(${arch} STREQUAL "arm64")
 externalproject_add(capnproto-${arch}
                      #DEPENDS
                      #capnproto-amd64
                      GIT_REPOSITORY
                      "https://github.com/capnproto/capnproto"
                      GIT_TAG
                      "v0.8.0"
                      SOURCE_DIR
                      "/tmp/3rdparty/capnproto-${arch}"
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
                      --prefix=${prefix}
                      --host=aarch64-linux-gnu
                      --target=aarch64-linux-gnu
                      --enable-shared
                      --with-external-capnp
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
endif()

# LMDB

if(${arch} STREQUAL "amd64")
  externalproject_add(liblmdb-${arch}
                      GIT_REPOSITORY
                      "https://github.com/LMDB/lmdb.git"
                      GIT_TAG
                      "LMDB_0.9.28"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/liblmdb-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      prefix=${prefix}
                      -C
                      ./libraries/liblmdb
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -C
                      ./libraries/liblmdb
                      -e
                      prefix=${prefix}
                      install)
elseif(${arch} STREQUAL "armhf")
  externalproject_add(liblmdb-${arch}
                      GIT_REPOSITORY
                      "https://github.com/LMDB/lmdb.git"
                      GIT_TAG
                      "LMDB_0.9.28"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/liblmdb-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      prefix=${prefix}
                      -C
                      ./libraries/liblmdb
                      CPP=/usr/bin/arm-linux-gnueabihf-g++
                      CC=/usr/bin/arm-linux-gnueabihf-gcc
                      CXX=/usr/bin/arm-linux-gnueabihf-g++
                      ld=arm-linux-gnueabihf-ld
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -C
                      ./libraries/liblmdb
                      -e
                      prefix=${prefix}
                      bindir=${prefix}/bin
                      libdir=${prefix}/lib
                      includedir=${prefix}/include
                      install)
elseif(${arch} STREQUAL "arm64")
  externalproject_add(liblmdb-${arch}
                      GIT_REPOSITORY
                      "https://github.com/LMDB/lmdb.git"
                      GIT_TAG
                      "LMDB_0.9.28"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/liblmdb-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      prefix=${prefix}
                      -C
                      ./libraries/liblmdb
                      CPP=/usr/bin/aarch64-linux-gnu-g++
                      CC=/usr/bin/aarch64-linux-gnu-gcc
                      CXX=/usr/bin/aarch64-linux-gnu-g++
                      ld=aarch64-linux-gnu-ld
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -C
                      ./libraries/liblmdb
                      -e
                      prefix=${prefix}
                      bindir=${prefix}/bin
                      libdir=${prefix}/lib
                      includedir=${prefix}/include
                      install)
endif()

# libnethogs

if(${arch} STREQUAL "amd64")
  externalproject_add(libnethogs-${arch}
                      # DEPENDS libpcap-${arch}
                      GIT_REPOSITORY
                      "https://github.com/raboof/nethogs"
                      GIT_TAG
                      "v0.8.6"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/libnethogs-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      libnethogs
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -e
                      install_dev)
elseif(${arch} STREQUAL "armhf")
  externalproject_add(libnethogs-${arch}
                      # DEPENDS libpcap-${arch}
                      GIT_REPOSITORY
                      "https://github.com/raboof/nethogs"
                      GIT_TAG
                      "v0.8.6"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/libnethogs-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      PREFIX=${prefix}
                      CPP=/usr/bin/arm-linux-gnueabihf-g++
                      CC=/usr/bin/arm-linux-gnueabihf-gcc
                      CXX=/usr/bin/arm-linux-gnueabihf-g++
                      ld=arm-linux-gnueabihf-ld
                      libnethogs
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -e
                      PREFIX=${prefix}
                      install_dev)
elseif(${arch} STREQUAL "arm64")
  externalproject_add(libnethogs-${arch}
                      # DEPENDS libpcap-${arch}
                      GIT_REPOSITORY
                      "https://github.com/raboof/nethogs"
                      GIT_TAG
                      "v0.8.6"
                      BUILD_IN_SOURCE
                      1
                      CONFIGURE_COMMAND
                      ""
                      SOURCE_DIR
                      "/tmp/3rdparty/libnethogs-${arch}"
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      -e
                      PREFIX=${prefix}
                      CPP=/usr/bin/aarch64-linux-gnu-g++
                      CC=/usr/bin/aarch64-linux-gnu-gcc
                      CXX=/usr/bin/aarch64-linux-gnu-g++
                      ld=aarch64-linux-gnu-ld
                      libnethogs
                      INSTALL_COMMAND
                      sudo make
                      ${MAKE_JOB_FLAGS}
                      -e
                      PREFIX=${prefix}
                      install_dev)
endif()

# Compiling armhf and arm64 versions of libzmq so that cross compiling of zyre works (need --enable-libunwind=no flag)
# libzmq
if(${arch} STREQUAL "armhf")
 externalproject_add(libzmq-${arch}
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/zeromq/libzmq.git"
                     GIT_TAG
                     "v4.3.2"
                     SOURCE_DIR
                     "/tmp/3rdparty/libzmq-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=arm-linux-gnueabihf
                     --target=arm-linux-gnueabihf
                     CC=/usr/bin/arm-linux-gnueabihf-gcc
                     CXX=/usr/bin/arm-linux-gnueabihf-g++
                     --prefix=${prefix}
                     --enable-libunwind=no
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)
elseif(${arch} STREQUAL "arm64")
 externalproject_add(libzmq-${arch}
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/zeromq/libzmq.git"
                     GIT_TAG
                     "v4.3.2"
                     SOURCE_DIR
                     "/tmp/3rdparty/libzmq-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=aarch64-linux-gnu
                     --target=aarch64-linux-gnu
                     CC=/usr/bin/aarch64-linux-gnu-gcc
                     CXX=/usr/bin/aarch64-linux-gnu-g++
                     --prefix=${prefix}
                     --enable-libunwind=no
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)
endif()


# High-level C binding for ØMQ

if(${arch} STREQUAL "amd64")
 externalproject_add(czmq-${arch}
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/zeromq/czmq.git"
                     GIT_TAG
                     "v4.2.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/czmq-${arch}"
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
elseif(${arch} STREQUAL "armhf")
 externalproject_add(czmq-${arch}
                     DEPENDS
                     libzmq-${arch}
                     GIT_REPOSITORY
                     "https://github.com/zeromq/czmq.git"
                     GIT_TAG
                     "v4.2.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/czmq-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=arm-linux-gnueabihf
                     --target=arm-linux-gnueabihf
                     CC=/usr/bin/arm-linux-gnueabihf-gcc
                     CXX=/usr/bin/arm-linux-gnueabihf-g++
                     --prefix=${prefix}
                     --enable-drafts
                     --with-libzmq=no
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
elseif(${arch} STREQUAL "arm64")
 externalproject_add(czmq-${arch}
                     DEPENDS
                     libzmq-${arch}
                     GIT_REPOSITORY
                     "https://github.com/zeromq/czmq.git"
                     GIT_TAG
                     "v4.2.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/czmq-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=aarch64-linux-gnu
                     --target=aarch64-linux-gnu
                     CC=/usr/bin/aarch64-linux-gnu-gcc
                     CXX=/usr/bin/aarch64-linux-gnu-g++
                     --prefix=${prefix}
                     --enable-drafts
                     --with-libzmq=no
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
endif()

# Zyre
if(${arch} STREQUAL "amd64")
 externalproject_add(zyre-${arch}
                     DEPENDS
                     czmq-${arch}
                     GIT_REPOSITORY
                     "https://github.com/zeromq/zyre.git"
                     GIT_TAG
                     "v2.0.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/zyre-${arch}"
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
elseif(${arch} STREQUAL "armhf")
 externalproject_add(zyre-${arch}
                     DEPENDS
                     czmq-${arch}
                     GIT_REPOSITORY
                     "https://github.com/zeromq/zyre.git"
                     GIT_TAG
                     "v2.0.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/zyre-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=arm-linux-gnueabihf
                     --target=arm-linux-gnueabihf
                     CC=/usr/bin/arm-linux-gnueabihf-gcc
                     CXX=/usr/bin/arm-linux-gnueabihf-g++
                     --prefix=${prefix}
                     PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig
                     --enable-drafts
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)
elseif(${arch} STREQUAL "arm64")
 externalproject_add(zyre-${arch}
                     DEPENDS
                     czmq-${arch}
                     GIT_REPOSITORY
                     "https://github.com/zeromq/zyre.git"
                     GIT_TAG
                     "v2.0.1"
                     SOURCE_DIR
                     "/tmp/3rdparty/zyre-${arch}"
                     BUILD_IN_SOURCE
                      1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     --host=aarch64-linux-gnu
                     --target=aarch64-linux-gnu
                     CC=/usr/bin/aarch64-linux-gnu-gcc
                     CXX=/usr/bin/aarch64-linux-gnu-g++
                     --prefix=${prefix}
                     PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig
                     --enable-drafts
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)
endif()

# OpenDHT
if(${arch} STREQUAL "amd64")
 externalproject_add(opendht-${arch}
                     DEPENDS
                     GIT_REPOSITORY
                     "https://github.com/savoirfairelinux/opendht.git"
                     GIT_TAG
                     "v2.4.10"
                     SOURCE_DIR
                     "/tmp/3rdparty/opendht-${arch}"
                     BUILD_IN_SOURCE
                     1
                     UPDATE_COMMAND
                     "./autogen.sh"
                     CONFIGURE_COMMAND
                     ./configure
                     PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
                     LDFLAGS=-L/usr/lib/x86_64-linux-gnu
                     BUILD_COMMAND
                     make
                     ${MAKE_JOB_FLAGS}
                     INSTALL_COMMAND
                     sudo make
                     install)
# MM TODO: working out a cross compile issue, this is not really needed at this time
#elseif(${arch} STREQUAL "armhf")
# externalproject_add(opendht-${arch}
#                     DEPENDS
#                     GIT_REPOSITORY
#                     "https://github.com/savoirfairelinux/opendht.git"
#                     GIT_TAG
#                    "v2.4.10"
#                     SOURCE_DIR
#                     "/tmp/3rdparty/opendht-${arch}"
#                     BUILD_IN_SOURCE
#                     1
#                    UPDATE_COMMAND
#                    "./autogen.sh"
#                     CONFIGURE_COMMAND
#                     ./configure
#                     --host=arm-linux-gnueabihf
#                     CC=/usr/bin/arm-linux-gnueabihf-gcc
#                    CXX=/usr/bin/arm-linux-gnueabihf-g++
#                     --prefix=${prefix}
#                     PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig
#                     Argon2_LIBS="-L/usr/lib/arm-linux-gnueabihf -largon2"
#                     Argon2_CFLAGS=-I/usr/include/arm-linux-gnueabihf
#                     GnuTLS_LIBS="-L/usr/lib/arm-linux-gnueabihf -lgnutls"
#                     GnuTLS_CFLAGS=-I/usr/include/arm-linux-gnueabihf
#                    MsgPack_LIBS="-L/usr/lib/arm-linux-gnueabihf -lmsgpackc"
#                     MsgPack_CFLAGS=-I/usr/include/arm-linux-gnueabihf
#                     Nettle_LIBS="-L/usr/lib/arm-linux-gnueabihf -lnettle"
#                     Nettle_CFLAGS=-I/usr/include/arm-linux-gnueabihf
#                     BUILD_COMMAND
#                     make
#                     ${MAKE_JOB_FLAGS}
#                     INSTALL_COMMAND
#                     sudo make
#                     install)
#elseif(${arch} STREQUAL "arm64")
# externalproject_add(opendht-${arch}
#                     DEPENDS
#                     GIT_REPOSITORY
#                     "https://github.com/savoirfairelinux/opendht.git"
#                     GIT_TAG
#                    "v2.4.10"
#                     SOURCE_DIR
#                    "/tmp/3rdparty/opendht-${arch}"
#                     BUILD_IN_SOURCE
#                    1
#                     UPDATE_COMMAND
#                    "./autogen.sh"
#                    CONFIGURE_COMMAND
#                    ./configure
#                     --host=aarch64-linux-gnu
#                     CC=/usr/bin/aarch64-linux-gnu-gcc
#                     CXX=/usr/bin/aarch64-linux-gnu-g++
#                     --prefix=${prefix}
#                     PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig
#                     Argon2_LIBS="-L/usr/lib/aarch64-linux-gnu -largon2"
#                     Argon2_CFLAGS=-I/usr/include/aarch64-linux-gnu
#                     GnuTLS_LIBS="-L/usr/lib/aarch64-linux-gnu -lgnutls"
#                     GnuTLS_CFLAGS=-I/usr/include/aarch64-linux-gnu
#                     MsgPack_LIBS="-L/usr/lib/aarch64-linux-gnu -lmsgpackc"
#                     MsgPack_CFLAGS=-I/usr/include/aarch64-linux-gnu
#                     Nettle_LIBS="-L/usr/lib/aarch64-linux-gnu -lnettle"
#                     Nettle_CFLAGS=-I/usr/include/aarch64-linux-gnu
#                     BUILD_COMMAND
#                     make
#                     ${MAKE_JOB_FLAGS}
#                     INSTALL_COMMAND
#                     sudo make
#                     install)
endif()


#libsoc

if(${arch} STREQUAL "amd64")
 externalproject_add(libsoc-${arch}
                    GIT_REPOSITORY
                    "https://github.com/jackmitch/libsoc.git"
                    GIT_TAG
                    "379f909690ea776cb6592bf246cce819b9da0ebd"
                    SOURCE_DIR
                    "/tmp/3rdparty/libsoc-${arch}"
                    BUILD_IN_SOURCE
                    1
                    UPDATE_COMMAND
                    autoreconf
                    -i
                    CONFIGURE_COMMAND
                    ./configure
                    --enable-shared
                    BUILD_COMMAND
                    make
                    ${MAKE_JOB_FLAGS}
                    INSTALL_COMMAND
                    sudo make
                    install)
elseif(${arch} STREQUAL "armhf")
 externalproject_add(libsoc-${arch}
                      GIT_REPOSITORY
                      "https://github.com/jackmitch/libsoc.git"
                      GIT_TAG
                      "379f909690ea776cb6592bf246cce819b9da0ebd"
                      SOURCE_DIR
                      "/tmp/3rdparty/libsoc-${arch}"
                      BUILD_IN_SOURCE
                      1
                      UPDATE_COMMAND
                      autoreconf
                      -i
                      CONFIGURE_COMMAND
                      ./configure
                      --prefix=${prefix}
                      --host=arm-linux-gnueabihf
                      --enable-board=beaglebone_black
                      BUILD_COMMAND
                      make
                      ${MAKE_JOB_FLAGS}
                      INSTALL_COMMAND
                      sudo make
                      install)
# No RaspberryPi 4 board yet in libsoc
#elseif(${arch} STREQUAL "arm64")
# externalproject_add(libsoc-${arch}
#                      GIT_REPOSITORY
#                      "https://github.com/jackmitch/libsoc.git"
#                      GIT_TAG
#                      "379f909690ea776cb6592bf246cce819b9da0ebd"
#                      SOURCE_DIR
#                      "/tmp/3rdparty/libsoc-${arch}"
#                      BUILD_IN_SOURCE
#                      1
#                      UPDATE_COMMAND
#                      autoreconf
#                      -i
#                      CONFIGURE_COMMAND
#                      ./configure
#                      --prefix=${prefix}
#                      --host=aarch64-linux-gnu
#                      --enable-board=????
#                      BUILD_COMMAND
#                      make
#                      ${MAKE_JOB_FLAGS}
#                      INSTALL_COMMAND
#                      sudo make
#                      install)
endif()

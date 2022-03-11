FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  apt-transport-https \
  cmake byacc flex libtool libtool-bin autoconf autogen libreadline-dev \
  htop openssl openssh-server mininet net-tools rdate \
  linuxptp gpsd chrony libssl-dev libffi-dev rng-tools \
  python3-dev python3-setuptools python3-pip \
  curl \
  libboost-dev \
  libpcap-dev libncurses5-dev \
  libzmq3-dev libsystemd-dev libcurl4-gnutls-dev \
  libgnutls28-dev \
  libmsgpackc2 libmsgpack-dev \
  nettle-dev libasio-dev

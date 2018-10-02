
# Welcome to the RIAPS Integration Repository

This repository indicates how to setup the various RIAPS environments from preloaded files and how these files were built.

## Application Developer Setup Instructions

### RIAPS Host Setup Instructions

The RIAPS host environment is based on a virtual machine setup using Ubuntu 18.04. Setting up the RIAPS host development environment (Linux VM) can be found in [Host Environment Setup Page](riaps-x86runtime/README.md).

### RIAPS Node Setup Instructions

The RIAPS node environment used for this project has been [TI Beaglebone Black](http://beagleboard.org/black).  Instructions on how to create a RIAPS Beaglebone Black SD Card Image can be found in [BBB Runtime Setup Page](riaps-bbbruntime/README.md).

### Testing the RIAPS Platform Environment

Once a RIAPS Host and the desired RIAPS Nodes are setup, a simple application can be used to test the environment.  Instructions for these test are found in [Environment Test Page](riaps-x86runtime/env_setup_tests/README.md).

## Developing the Base RIAPS SD Card Image

The instructions and scripts provided were used to develop the base RIAPS SD Card image. This base image is used when setting up a RIAPS Node using a TI Beaglebone Black board.  The SD card image includes basic third party packages and configures the environment for the RIAPS platform. The intent is to provide a base image that is only periodically updated and to reduce the time necessary for application developers to create RIAPS nodes.  Instructions for creating this image is located in [Base RIAPS SD Card Image Creation Page](bbb-creation-files/README.md).

## Developing the Preloaded RIAPS Virtual Machine

The instructions and scripts provided were used to develop the preloaded RIAPS virtual machine exported appliance (.ova). This appliance file is used when setting up a RIAPS host environment on a computing device.  The virtual machine includes basic third party packages and configures the environment for the RIAPS platform. The intent is to provide quick way for application developers to create RIAPS host environment.  Instructions for creating this virtual machine is located in [Preloaded RIAPS Virtual Machine Creation Page](riaps-x86runtime/vm-creation-readme.md).

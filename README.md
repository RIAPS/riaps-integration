[![Build Status](https://travis-ci.com/RIAPS/riaps-integration.svg?token=pyUEeBLkG7FqiYPhyfxp&branch=master)](https://travis-ci.com/RIAPS/riaps-integration)

# Welcome to the RIAPS documentation!

## RIAPS Host Setup Instructions

The RIAPS host environment is based on a VirtualBox setup using Ubuntu 16.04. Setting up the RIAPS host development environment (Linux VM) can be found in [Host Environment Setup Page](riaps-x86runtime/README.md).

## RIAPS Node Setup Instructions

The RIAPS node environment used for this project has been [TI Beaglebone Black](http://beagleboard.org/black).  Instructions on how to create a RIAPS Beaglebone Black SD Card Image can be found in [BBB Runtime Setup Page](riaps-bbbruntime/README.md).

## Testing the RIAPS Platform Environment

Once a RIAPS Host and the desired RIAPS Nodes are setup, a simple application can be used to test the environment.  Instructions for these test are found in [Environment Test Page](riaps-x86runtime/env_setup_tests/README.md).

## RIAPS Platform Tutorials

As tutorials are developed, they will be placed where [example](doc/tutorials/example.md) is located.

## Developing the Base RIAPS SD Card Image

The instructions and scripts provided were used to develop the base RIAPS SD Card image. This base image is used when setting up a RIAPS Node using a TI Beaglebone Black board.  The SD card image includes basic third party packages and configures the environment for the RIAPS platform. The intent is to provide a base image that is only periodically updated and to reduce the time necessary for application developers to create RIAPS nodes.  Instructions for creating this image is located in [Base RIAPS SD Card Image Creation Page](bbb-creation-files/README.md).

## Repository Notes

In order to use the integration scripts and setup your environment correctly you will need to download a number of other packages from the RIAPS organization. At the time of these instructions, RIAPS is a private organization and you need to have at least read-level access to the repositories. To get this access, please contact Prof. Gabor Karsai or Prof. Abhishek Dubey.

Once you get the read level access, you need to set up an OAUTH Token.  Read https://developer.github.com/v3/oauth/. Create a personal access token as discussed on the page. Set the SCOPE to "repo". That will grant the token access to "Grants read/write access to code, commit statuses, invitations, collaborators, adding team memberships, and deployment statuses for public and private repositories and organizations."

Once you have the token you must use it everytime you want to download the new release in your machine. A trick is to create an environment variable GITHUB_OAUTH_TOKEN with the token value in your bash profile.

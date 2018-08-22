[![Build Status](https://travis-ci.com/RIAPS/riaps-integration.svg?token=pyUEeBLkG7FqiYPhyfxp&branch=master)](https://travis-ci.com/RIAPS/riaps-integration)



# riaps-integration

In order to use the integration scripts and setup your environment correctly you will need to download a number of other packages from the RIAPS organization. At the time of these instructions, RIAPS is a private organization and you need to have at least read-level access to the repositories. To get this access, please contact Prof. Gabor Karsai or Prof. Abhishek Dubey.

Once you get the read level access, you need to set up an OAUTH Token.  Read https://developer.github.com/v3/oauth/. Create a personal access token as discussed on the page. Set the SCOPE to "repo". That will grant the token access to "Grants read/write access to code, commit statuses, invitations, collaborators, adding team memberships, and deployment statuses for public and private repositories and organizations."

Once you have the token you must use it everytime you want to download the new release in your machine. A trick is to create an environment variable GITHUB_OAUTH_TOKEN with the token value in your bash profile.

## example

example can be found in [this file](doc/example.md)

# To Setup RIAPS Development Environment

- Setting up the RIAPS host development environment (Linux VM) can be found in the riaps-x86runtime folder.
- Creating a RIAPS Beaglebone Black SD Card Image can be found in the riaps-bbbruntime folder.

# Integration Testing

The following examples are used in the integration testing to make sure the RIAPS framework functionality is working.  The deployment file (.depl) may need to be adjusted to work on different platforms.  

| Tests   | Functionality      |
| ---------- |:------------------:|
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/WeatherMonitor | Publish/Subscribe Ports|
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/DistributedAverager | Publish/Subscribe Ports|
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/DistributedEstimator | Publish/Subscribe & Request/Reply Ports |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/ReqRep | Request/Reply Ports |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/CltSrv | Client / Server Ports |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/QryAns | Query/Answer Ports |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/TimerS | Timer Ports |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/DistributedAveragerIO |  Device Component IO |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/EchoIO | Device Component / Actor Machinery |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/DistributedEstimatorCapnp | Capnp Proto Interfacing |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/Limits | CPU / Memory Resource Limiting |
| https://github.com/RIAPS/riaps-pycom/tree/master/tests/ReqRepLib | Library Module |



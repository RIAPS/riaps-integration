# RIAPS Eclipse Setup and Plugins

The RIAPS Virtual Machine is configured with an Eclipse IDE for C/C++ Developers - 2024-06.

Configuration used to setup the RIAPS configured tool set is listed below:

## Apt Packages Required

Install **clang-format** using apt.

## Eclipse Plugins

### Plugin installation using "Eclipse Marketplace..."

Install:

* Eclipse Xtext (2.19.0 or later)
* Eclipse Xtend (2.19.0 or later)
* JSON Editor Plugin (1.1.2 or later)
* PyDev for Eclipse - Python IDE (7.4.0 or later)

### Plugin installation using "Install New Software ..."

* Work with: "--All Available Sites--"
  * "CDT Optional Features", select C/C++ StandaloneGit Developer Resources
  * Git integration for Eclipse - Task focused interface
	   - From Eclipse Marketplace:  Eclipse Xtend, Xtext,

#### RIAPS DSML Plugin

* Add a repository:  http://riaps.isis.vanderbilt.edu/dsml

* Select "RIAPS Development Tools"

# RIAPS Eclipse Setup and Plugins

The RIAPS Virtual Machine is configured with an Eclipse IDE 2018-12.  A compressed file with this IDE configured for RIAPS tools can be found in the RIAPS download page (https://riaps.isis.vanderbilt.edu/downloads) under the latest version.  The file contains the IDE folder, a default "workspace" folder, example project files (imported into the default workspace), and riaps launch files that can be imported into the any workspace.

Configuration used to setup the RIAPS configured tool set is listed below:

## Apt Packages Required

Install **clang-format** using apt.

## Eclipse Plugins

### Plugin installation using "Eclipse Marketplace..."

Install:

* Eclipse Xtend (2.16.0 or later)
* JSON Editor Plugin (1.1.2 or later)
* PyDev for Eclipse - Python IDE (7.0.3 or later)

### Plugin installation using "Install New Software ..."

#### CDT

* Work with: CDT - http://download.eclipse.org/tools/cdt/releases/9.6 or later

* Select "C/C++ Development Tools"

*	Under "CDT Optional Features", select the following:

 - C/C++ Autotools support Developer Resources
 - C/C++ GCC Cross Compiler Support Developer Resources
 - C/C++ GDB Hardware Debugging Developer Resources
 - C/C++ Memory View Enhancements Developer Resources
 - C/C++ Remote Launch Developer Resources
 - C/C++ Standalone Debugger Developer Resources
 - C/C++ Visual C++ Support
 - C/C++ Visual C++ Support Developer Resources

#### XText SDK

* Work with: "--All Available Sites--"

* Select "Xtext Complete SDK"

#### RIAPS DSML Plugin

* Add a repository:  http://riaps.isis.vanderbilt.edu/dsml with

 ```
 Username: riaps
 Password: riapsdsml
 ```

* Select "RIAPS Domain Specific Modeling Environment"

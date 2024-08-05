# RIAPS Debian Packages Setup in Apt Repository

This directory outlines the directory structure used to create the RIAPS apt repositories that is posted on the RIAPS server.  One repository will have Ubuntu packages and the other will have Debian packages.  The resultant repos will be `https://riaps.isis.vanderbilt.edu/aptrepo/` for Ubuntu packages and `https://riaps.isis.vanderbilt.edu/aptrepo-debian/` for Debian packages.  Both are signed by the same key.

Steps used to create the apt repositories are:

1) Download and untar the latest riaps-release.tar.gz file from https://github.com/RIAPS/riaps-integration/releases for the Ubuntu packages.
   
2) Sign each of the Ubuntu packages using ```dpkg-sig --sign <keyname> *.deb```.  It will ask for the appropriate passcode.  This assumes a secret key is setup already.

3) Download and untar the latest Debian packages which are built on a separate system and uploaded to the release.  For v2.0.0, the uploaded file is name `riaps-pkgs-bookworm.tar.gz`.

4) Sign each of the Debian packages using ```dpkg-sig --sign <keyname> *.deb```.  It will ask for the appropriate passcode.  This assumes a secret key is setup already.

5) Clone [riaps-integration](https://github.com/RIAPS/riaps-integration) repository and move into the `riaps-repo` folder.

6) Clean with ```git clean -fxd```

>Note: The following instructions indicate how to setup the repositories.  It will need to be done for both the Ubuntu and Debian repositories.

1) Check the repo to make sure it is ready for the appropriate Ubuntu or Debian release.

```
reprepro check
```

5) Copy the files into the repository structure.  It will ask for the appropriate passcode.  This assumes a secret key is setup already.

```
reprepro -S main includedeb <codename> <location of packages for codename>/*.deb
```

6) Tar the dists/ and pool/ directories and move them to the RIAPS server locations.

## Signing the Download Items

1) Save file hashes to SHA256SUMS file
```
sha256sum file1 file2 > SHA256SUMS
```

2) Create SHA256SUMS.sig
```
gpg --detach-sign SHA256SUMS
```

## Verifying Download Signatures

1) Verify the GPG signature on SHA256SUMS
```
gpgv --keyring /etc/apt/trusted.gpg SHA256SUMS.sig SHA256SUMS
```
Output should be ***Good signature from X***

2) Verify the SHA-256 hashes
```
sha256sum --check SHA256SUMS
```

Output should be ***fileX:  OK*** for each file.

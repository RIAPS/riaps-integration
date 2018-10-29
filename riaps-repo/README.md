# RIAPS Debian Packages Setup in Apt Repository
 
This directory outlines the directory structure used to create the RIAPS apt repository that is posted on the RIAPS server. 
Steps used to create the apt repository are:
 
1) Download and untar the latest riaps-release.tar.gz file from https://github.com/RIAPS/riaps-integration/releases.
 
2) Clone [riaps-integration](https://github.com/RIAPS/riaps-integration) repository
 
3) Clean with ```git clean -fxd```
 
4) Check the repo to make sure it is ready for the appropriate ubuntu release.  Currently setup for bionic.
 
```
reprepro check
```
 
5) Copy the files into the repository structure.  It will ask for the appropriate passcode.  This assumes a secret key is setup already.
 
```
reprepro -S main includedeb bionic ../../riaps-release/*.deb
```
 
6) Tar the dists/ and pool/ directories and move them to the RIAPS server location.
 
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

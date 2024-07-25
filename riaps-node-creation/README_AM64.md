# Create RIAPS AM64x Base Image (??GB)

These are instructions on how the AM64x Base image.  The image build scripts are located in the [RIAPS/riaps-ti-bdebstrap](https://github.com/RIAPS/riaps-ti-bdebstrap) repository under the **develop** branch (master branch is left as the Texas Instruments/ti-bdebstrap repository that is forked).

## How to Build the Image

This work should be done on a Linux machine or VM with Ubuntu 22.04. See the notes in the `riaps-ti-bdebstrap` repo for dependency setups.  The repository includes a Jenkinsfile for automated builds on a Jenkins build system.

1) Clone the [RIAPS/riaps-ti-bdebstrap](https://github.com/RIAPS/riaps-ti-bdebstrap) repository and checkout the **develop** branch

2) Run ```./package.sh``` to build the image.  This build can take up to 4 hours.

3) The resulting image will be located in `build/riaps-am64-bookworm-*` as a `.wic.xz` file.  The `*` is the version number located in `version.sh`.

4) Use `balenaEtcher` to copy the image to the SD card

> Note: Release images do not include the RIAPS packages installed.

Resulting image information:

```
Username:  root
Password:  <none>
Kernel:    v6.1.xx-rtxx-k3-rt
```
## This ISO Builder

This ISO builder was basically a combination of previous efforts from Ubuntu
Budgie (budgie-remix at the time), some stuff from livecd-rootfs from launchpad, 
Elementary OS, and most importantly VanillaOS thanks to the amazing devs from all around!
Vanilla-OS Link: https://github.com/Vanilla-OS/os

## Why not just fork from livecd-rootfs?

We do not posses enough IQ to do that! 

## Building Locally

As UCR is built with the Debian version of `live-build`, not the Ubuntu patched version, it's easiest to build an iso in a Debian VM or container. This prevents messing up your host system too.

The following example uses Docker and assumes you have Docker correctly installed and set up:

 1) Clone this project & `cd` into it:

    ```
    git clone https://github.com/PikaOS-Linux/os.git && cd os
    ```

 2) Configure the channel in the `etc/terraform.conf` (unstable, all).

 3) Run the build:

    ```
    docker run --privileged -i -v /proc:/proc \
        -v ${PWD}:/working_dir \
        -w /working_dir \
        debian:latest \
        /bin/bash -s etc/terraform.conf < build.sh
    ```

 4) When done, your image will be in the `builds` folder.

## Release tags

Released usually follows the Ubuntu release cycle i.e. `22.10, 23.04..`. Releases named `22.10-r1` means that the release is still 22.10 with just a refreshed of the repositories and packages, this is meant to help users getting the latest release with updated packages, with more fixes and features OTB.


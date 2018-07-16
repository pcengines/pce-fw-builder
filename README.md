pce-fw-builder
==============

This project aims to provide infrastructure for reliable building firmware for
PC Engines platforms. It replace legacy approach from
[release_manifests](https://github.com/pcengines/release_manifests) and utilize
official [coreboot-sdk](https://hub.docker.com/r/coreboot/coreboot-sdk/)
wherever it is possible. Unfortunately legacy builds `coreboot-4.0.x` require
toolchain from pre-coreboot-sdk era that's why we created
`pce-fw-builder-legacy`.

Keep in mind that this tool works only for coreboot releases not older than
v4.6.9 and v4.0.17. For older releases use the procedure described in
[release_manifests](https://github.com/pcengines/release_manifests).
Also, due to a typo in configuration file, when building v4.6.9 you will be asked
if you want to `Include CPU microcode in CBFS` - just press Enter and the build
process will continue.

Usage
-----

Initial run may take some time. Below procedures assume that Docker is
correctly installed and current user is in `docker` group. Script automatically
detect with which codebase it deals with and choose toolchain accordingly.

If you don't want to use default containers take a look at [this paragraph](#building-docker-image).

```
$ git clone https://github.com/pcengines/pce-fw-builder.git -b <most_recent_tag>
```
Remember to use a recent tag in the command above.
```
$ cd pce-fw-builder
$ ./build.sh
usage: ./build.sh <command> [<args>]

Commands:
    dev-build    build PC Engines firmware from given path
    release      build PC Engines firmware from branch/tag/commit of
                 upstream or PC Engines fork of coreboot
    release-CI   release command prepared to be run in Gitlab CI

dev-build: ./build.sh dev-build <path> <platform> [<menuconfig_param>]
    <path>                full path to coreboot source
    <platform>            apu1, apu2, apu3, apu4 or apu5
    <menuconfig_param>    menuconfig interface, give 'help' for more information

release: ./build.sh release <ref> <platform> [<menuconfig_param>]
    <ref>                 valid reference branch, tag or commit
    <platform>            apu1, apu2, apu3, apu4 or apu5
    <menuconfig_param>    menuconfig interface, give 'help' for more information

```

Development use case
--------------------

This repository can be very useful for developers. First there is `dev-build`
which will build coreboot tree according to provided revision, but assuming you
starting from scratch and want to work with release version `v4.6.x` for apu2
you can simply:

```
./build.sh release v4.6.x apu2
```

This will pull everything needed and build release. Then you can play with code in `release/coreboot` and for rebuild simply:

```
./build.sh dev-build $PWD/release/coreboot apu2
```

Building Docker image
---------------------

## Mainline

```
docker build -t pcengines/pce-fw-builder -f Dockerfile.ml .
```

## Legacy

```
docker build -t pcengines/pce-fw-builder-legacy -f Dockerfile.legacy .
```

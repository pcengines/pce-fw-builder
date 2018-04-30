pce-fw-builder
==============

This project aims to provide infrastructure for reliable building firmware for
PC Engines platforms. It replace legacy approach from [release_manifests](https://github.com/pcengines/release_manifests)
and utilize official [coreboot-sdk](https://hub.docker.com/r/coreboot/coreboot-sdk/).

Usage
-----

Initial run may take some time. Below procedures assume that Docker is
correctly installed and current user is in `docker` group.

```
git clone https://github.com/pcengines/pce-fw-builder.git
cd pce-fw-builder
./build.sh release <tag|branch> <platform> [<menuconfig-param>]
# ./build.sh dev-build <path> <platform> [<menuconfig-param>]
```

* `<tag|branch>` - any valid branch or tag of [PC Engines coreboot repository](https://github.com/pcengines/coreboot)
* `<platform>` - one of supported platforms `apu1`, `apu2`, `apu3`, `apu4` or `apu5`
* `<path>` - full path to coreboot source

TODO
----

* support for `< v4.6.5`
* support for building all binaries

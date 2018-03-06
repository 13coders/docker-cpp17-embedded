# A Docker image for Embedded C++17 CI builds

This Docker container extends `13coders/cpp17-base`, [located in
DockerHub](https://hub.docker.com/r/13coders/cpp17-base/) with tooling
for ARM Cortex-M development. Please check the base image for more
detailed documentation.

## Features

The base image contains a complete set of C++ tooling for amd64
development, as well as extending from the official Jenkins
image. Added components in this image are:

| Component | Source | Version | Notes |
| --- | ---| --- | --- |
| [usbutils](https://packages.debian.org/stretch/usbutils) | apt-get | | Gives `lsusb` for debugging USB connection issues |
| [GNU Arm Embedded](https://developer.arm.com/open-source/gnu-toolchain/gnu-rm) | S3/binary | 7-2017-q4-major | Toolchain for Cortex-M/R development |

In addition, this image adds the `jenkins` user to the `plugdev` group
for connection to USB hardware for deployment/flash of binaries for
on-device testing or profiling - or just as a reproducible
version-controlled deployment for other manual test with hardware
diagnostic tools and debuggers.

It's expected that this image will in turn be extended for specific
debug toolchains.

## Running the CI server

Please consult the `13coders/cpp17-base` documentation for a fuller
description of the container launch.

We'll note here that it's also generally necessary to pass USB devices
into the container launch for any embedded USB hardware that you need
to interact with. It is strongly preferred to do this rather than run
the container as `--privileged`.

On the host side, running the `lsusb` command would show the USB
device we want to access in the container:

```
$ lsusb
...
Bus 001 Device 009: ID 1366:0101 XYZ PLC JTAG/SWD Debug Probe
...
```

The bus and device are then identified to Docker when we launch the
container with the `--device` argument shown below (see the base image
documentation for an explanation of the other command-line arguments):

```
$ docker run \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /path/to/local/dir:/var/jenkins_home \
  --cap-add SYS_PTRACE \
  --device=/dev/bus/usb/001/009 \
  13coders/cpp17-base

```

It's worth noting also that Docker containers are immutable after
launch, and although unplugging and re-inserting USB cables for
embedded hardware on the host side might result in `udev` picking up
the reinserted device, the container will not see it. Leave embedded
test hardware plugged in throughout the container run.

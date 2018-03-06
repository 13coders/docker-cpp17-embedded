# For a detailed description and guide on how best to use this Docker
# image, please look at the README.  Note that this image is set up to
# pull many of its requirements from an S3 bucket rather than the
# public internet. Unless you want to build this Docker image
# yourself, we'd recommend just using as-is with a docker pull.

# The image extends from the 13coders/cpp17-base image (always an
# identified version, never latest...), which contains GCC6 and Clang
# (both for amd64) and additional tooling that helps in CI builds. The
# purpose of this image is to add dependencies and tools that are
# common to developing for ARM Cortex-M platforms.

FROM 13coders/cpp17-base:1.1
MAINTAINER Mike Ritchie <mike@13coders.com>
LABEL description="Docker image for C++ dual-target ARM Cortex-M development"

# These environment variables for the AWS command line need to be
# passed to the docker build command. This is preferable to persisting
# credentials in the Docker image. Note that these credentials will be
# visible in your (host) shell history, so clear them down. Also use
# an IAM role in AWS with highly constrained privileges - potentially
# read-only access to the single S3 bucket containing the
# dependencies.

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG AWS_BUCKET

# Additional configuration has to take place using root user.

USER root

# USB utilities are essential for diagnosing issues connecting to
# embedded hardware over USB from the Docker container.

RUN apt-get install -y usbutils

# We add Jenkins to the plugdev group to allow access to USB
# devices. This will still require that (preferably) a device is
# mapped in to the run command with --device, or (less ideal) that the
# container is run as --privileged

RUN adduser jenkins plugdev

# Version of GCC ARM Embedded that we need to fetch from S3 bucket.

ARG v_gcc_arm=gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2

RUN aws s3 cp s3://${AWS_BUCKET}/${v_gcc_arm} .
RUN mkdir -p /opt/tools/gcc-arm-none-eabi
RUN tar xf ${v_gcc_arm} -C /opt/tools/gcc-arm-none-eabi --strip 1

# Bail back out to Jenkins user for setting persistent environment
# variable changes

USER jenkins

# Set the path to pick up the GNU ARM embedded tools we've added.

ENV PATH "$PATH:/opt/tools/gcc-arm-none-eabi/bin"

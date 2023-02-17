# PikaOS ISO production

This repository contains the tools necessary for building PikaOS ISOs.

## Building

```
docker run --privileged -i -v /proc:/proc \
    -v ${PWD}:/working_dir \
    -w /working_dir \
    debian:latest \
    /bin/bash -s etc/terraform.conf < build.sh
```

The configuration can be changed in `mk/config.mk`.

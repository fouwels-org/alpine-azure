<!--
SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>

SPDX-License-Identifier: MIT
-->

# Azure Alpine Linux builder

## Packer

- Downloads and verifies the Alpine-virt ISO
- Boots in QEMU and uses `setup-alpine` to perform an installation
- Serves setup-alpine `answers` file through Packer/http
- Installs the `hvtools` package and enables the `hv_kvp_daemon` for azure hyper-v guest integration
- Builds and installs the azure `WAAgent`

## Usage

- Run `make build` where your host platform is one of `macos`, `linux`. Will call packer and configure the correct acceleration options for the platform.
- Run `make convert` to convert the image from Qcow2 to VHD for Azure.

## Notes
- The initial root password for the image is required to be provided [1] as environment variable `ALPINE_ROOT`
- A full build should be expected to take 1-2 minutes, excluding ISO Download.
- Image can be started locally with QEMU for testing with `make local`

## Prerequisites

- Requires: make, packer, QEMU and either KVM or HVF for acceleration


[1] For example `export ALPINE_ROOT=$(openssl rand -hex 12) && echo $ALPINE_ROOT `

Inspired by https://github.com/tomconte/packer-alpine-azure (unmaintained)
<!--
SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>

SPDX-License-Identifier: MIT
-->

# Azure Alpine Linux builder

## Usage

- Run `make build` on a host platform that is one of `macos`, `linux`. 
- Will call packer with the correct acceleration options configured for the platform.
- Will output as `alpine-3.14.3-r0.vhd` within `./out`

## Process - Packer

- Downloads and verifies the `alpine-virt` ISO
- Boots in QEMU and uses `setup-alpine` to perform an installation
- Serves setup-alpine `answers` file through Packer/http
- Installs the `hvtools` package and enables the `hv_kvp_daemon` for azure hyper-v guest integration
- Builds and installs the azure `WAAgent`

## Notes
- The initial root password for the image is required to be provided [1] as environment variable `ALPINE_ROOT`
- This will be baked into the image, and should be used for initial login over serial console once deployed to azure
- A full build should be expected to take 1-2 minutes, excluding ISO Download.
- You can expect to wait for "Waiting for SSH to become available..." for a number of minutes, while the system bootstraps via CLI.

## Development
- Image can be started locally with for testing via qemu/kvm via `make local`

## Prerequisites
- Requires: make, packer, QEMU and either KVM or HVF for acceleration


[1] For example `export ALPINE_ROOT=$(openssl rand -hex 12) && echo $ALPINE_ROOT `

Inspired by https://github.com/tomconte/packer-alpine-azure (unmaintained)
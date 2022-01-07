<!--
SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>

SPDX-License-Identifier: MIT
-->

# Azure Alpine Linux builder

## Usage

- Export `ALPINE_ROOT=<root password>`, where `<root passsword>` will form the password for the root user account within the image.
- Run `make build`
- Pick up the `alpine-3.15.0-r0.vhd` output to within `./out`

## Deployment - Azure:
- Azure Subscription: Create an Image Library (Azure Compute Library)
- Image Library: Create an Image Profile (VM Image Definition)
- Image Profile: Create an Image Version (VM Image Definition Version)
- Image Profile Version: Upload the created VHD

## Instantiation - Azure:
- Deploy a VM from the deployed Image Profile
- VM: Reset Password: Set the SSH key for a connecting user via WAAgent
- (alpine specific) VM: Reset Password: Set a local password for this user (see notes)
- Connect over SSH with the newly created user/key

## Process - Packer
- Downloads and verifies the `alpine-virt` ISO
- Boots in QEMU and uses `setup-alpine` to perform an installation
- Serves setup-alpine `answers` file through Packer/http
- Installs the `hvtools` package and enables the `hv_kvp_daemon` for azure hyper-v guest integration
- Builds and installs the azure `WAAgent`

## Security:
- WAAGent is run with `OS.EnableFirewall=n`, as it's IPtables declarations do not currently function correctly under Alpine. No claim is made on the impact of this to your specific setup and configuration. Patches welcome if anyone has a solution to enable this without conflict.
- The Root user is made available locally, including over the serial console, with the password `ALPINE_ROOT` defined when the image is created, this should be changed after deployment if local access and/or over serial console is a concern and/or desired feature.

## Development
- Image can be auto-started locally with for testing after built via qemu/kvm via `make local`

## Notes
- [0] The root user while not available over SSH, will be available locally, including over the Azure Serial Console.
- [1] A password is required to be set for newly created users, in addition to a public key, via the azure console. This is required to unlock the user and allow authentication, even over SSH when key based.
- A full build should be expected to take 1-2 minutes, excluding ISO Download.
- You can expect to wait for "Waiting for SSH to become available..." for a number of minutes, while the system bootstraps via CLI.
- ALPINE_ROOT one liner: `export ALPINE_ROOT=$(openssl rand -hex 12) && echo $ALPINE_ROOT`

## Prerequisites
- Requires: make, packer, QEMU and either KVM or HVF for acceleration
- Run `make deps-<platform>` to install automatically, where platform is the host distribution, and currently one of `alpine|..`.

## License:
MIT and/or MIT compatible

See SPDX tags for specific copyright attributions


Inspired by https://github.com/tomconte/packer-alpine-azure (unmaintained)



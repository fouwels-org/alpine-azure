# SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>
#
# SPDX-License-Identifier: MIT

LOG=0 			# Enable Packer Logging
CDIR=cache 		# Packer Cache Dir
KI=10ms 		# Packer Keyboard Interval

ifeq ($(ALPINE_ROOT),)
  	$(error Environment variable ALPINE_ROOT is required to be set)
endif

ifeq ($(shell uname -s),Linux)
	ACCEL=kvm
else ifeq ($(shell uname -s),Darwin)
	ACCEL=hvf
else
	$(error Invalid host platform, build supports Linux, Darwin (MacOS))
endif

build:
	PACKER_KEY_INTERVAL=$(KI) PACKER_CACHE_DIR=$(CDIR) PACKER_LOG=$(LOG) packer build -var p_root=$(ALPINE_ROOT) -var accelerator=$(ACCEL) alpine.pkr.hcl

local:
	qemu-system-x86_64 \
		-device ahci,id=ahci \
		-device ide-hd,drive=drive-os,bus=ahci.0 \
		-drive id=drive-os,file=output-alpine/alpine.qcow2,cache=none,if=none \
		-device virtio-net,netdev=n1 \
		-netdev user,id=n1 \
		-serial mon:stdio \
		-nodefaults \
		-nographic \
		-machine type=q35,accel=$(ACCEL)

convert: 
	qemu-img convert -o subformat=fixed,force_size -O vpc ./output-alpine/alpine.qcow2 ./output-alpine/alpine.vhd

clean:
	rm -rf output-*

deps-alpine:
	apk add make packer qemu-system-x86_64 qemu-img

# SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>
#
# SPDX-License-Identifier: MIT

variables {
  accelerator = "unset"
  display = "unset"
  p_root = "unset"
  v_alpine_major = "3.15"
  v_alpine_minor = "0"
  v_internal = "r0"
  v_waagent = "2.4.0.2"
  c_alpine = "e97eaedb3bff39a081d1d7e67629d5c0e8fb39677d6a9dd1eaf2752e39061e02"
}

locals {
  label = format("alpine-%s.%s-%s", var.v_alpine_major, var.v_alpine_minor, var.v_internal)
}

build {
  source "source.qemu.alpine" {}
  provisioner "shell" {
    environment_vars = [
      "VERSION_WAAGENT=${var.v_waagent}"
    ]
    scripts = [
      "scripts/provision.sh"
    ]
  }
  post-processor "shell-local" {
    inline = [
      "qemu-img convert -o subformat=fixed,force_size -O vpc ./output-alpine/${local.label}.qcow2 ./output-alpine/${local.label}.vhd",
      "cd output-alpine && ln -s ${local.label}.qcow2 alpine.qcow2"
    ]
  }
}

source "qemu" "alpine" {
  vm_name = "${local.label}.qcow2"
  accelerator = var.accelerator
  machine_type = "q35"
  boot_command = [
    "root<enter>",
    "ifconfig eth0 up && udhcpc -i eth0<enter>",
    "wget -O /answers http://{{.HTTPIP}}:{{.HTTPPort}}/answers<enter>", 
    "setup-alpine -f /answers<enter><wait5>", 
    "${var.p_root}<enter>", 
    "${var.p_root}<enter>", 
    "y<enter>",
    "mount /dev/vda2 /mnt<enter>",
    "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /mnt/etc/ssh/sshd_config<enter>",
    "umount /mnt<enter>", "eject -s /dev/cdrom<enter>", 
    "reboot<enter>",
    ]
  headless = "true"
  memory = 2048
  boot_wait = "10s"
  communicator = "ssh"
  disk_size = "350"
  display = var.display
  http_directory = "srv"
  http_port_min = 8080
  http_port_max = 8080
  iso_checksum  = var.c_alpine
  iso_url = "https://dl-cdn.alpinelinux.org/alpine/v${var.v_alpine_major}/releases/x86_64/alpine-virt-${var.v_alpine_major}.${var.v_alpine_minor}-x86_64.iso"
  shutdown_command = "poweroff"
  skip_compaction = "true"
  ssh_password = var.p_root
  ssh_username = "root"
}
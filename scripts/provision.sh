# SPDX-FileCopyrightText: 2021 Kaelan Thijs Fouwels <kaelan.thijs@fouwels.com>
#
# SPDX-License-Identifier: MIT

#!/bin/ash

set -e

apks() {
    apk add --no-cache hvtools openssl sudo bash shadow parted iptables sfdisk python3 py3-setuptools py3-pip util-linux
    ln -s /usr/bin/python3 /usr/bin/python
}
apks

hv_tools() {
    rc-update add hv_fcopy_daemon
    rc-update add hv_kvp_daemon
    rc-update add hv_vss_daemon
}
hv_tools

waagent() {
    wget -q https://github.com/Azure/WALinuxAgent/archive/v${VERSION_WAAGENT}.tar.gz && tar xzf v${VERSION_WAAGENT}.tar.gz && rm v${VERSION_WAAGENT}.tar.gz
    cd WALinuxAgent-${VERSION_WAAGENT} && python3 setup.py install
    cd .. && rm -rf WALinuxAgent-${VERSION_WAAGENT}

    cat >/etc/init.d/waagent <<EOF
#!/sbin/openrc-run

name=waagent
cfgfile="/etc/waagent.conf"
command="/usr/sbin/waagent"
command_args="--daemon"
command_user="root"
pidfile="/run/waagent/waagent.pid"
start_stop_daemon_args=""
command_background="yes"

depend() {
    need net sshd
}

start_pre() {
    checkpath --directory --owner $command_user:$command_user --mode 0775 /run/waagent /var/log/waagent.log
}
EOF
    chmod +x /etc/init.d/waagent
    rc-update add waagent default
    # Disable WAAGent messing with iptables, does not function correctly.
    sed -i 's/OS.EnableFirewall=y/OS.EnableFirewall=n/g' /etc/waagent.conf
}
waagent

kernel_opts() {
    sed -i 's/^default_kernel_opts="[^"]*/\0 console=ttyS0 earlyprintk=ttyS0 rootdelay=300/' /etc/update-extlinux.conf
    update-extlinux
}
kernel_opts

sshd() {
    echo 'Ciphers aes256-ctr' >>/etc/ssh/sshd_config
    echo 'KexAlgorithms curve25519-sha256' >>/etc/ssh/sshd_config
    echo 'MACs hmac-sha2-512' >>/etc/ssh/sshd_config
    echo 'HostKeyAlgorithms ssh-ed25519' >>/etc/ssh/sshd_config
    echo 'Compression no' >>/etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's:#HostKey /etc/ssh/ssh_host_ed25519_key:HostKey /etc/ssh/ssh_host_ed25519_key:g' /etc/ssh/sshd_config

}
sshd

#!/usr/bin/env sh

set -e
wget https://raw.github.com/coreos/init/master/bin/coreos-install
chmod +x coreos-install
./coreos-install -d /dev/sda -C stable -c /root/cloud-config.yaml
reboot

#!/usr/bin/env sh

# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0

set -e
wget https://raw.github.com/coreos/init/master/bin/coreos-install
chmod +x coreos-install
./coreos-install -d /dev/sda -C stable -c /root/cloud-config.yaml
reboot

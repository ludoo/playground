#!/usr/bin/env sh

set -e
sudo mv /home/core/cloud-config.yaml /var/lib/coreos-install/user_data
sudo chown root:root /var/lib/coreos-install/user_data
sudo chmod 600 /var/lib/coreos-install/user_data


# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0

output "id" {
  value = "${hcloud_server.server.id}"
}

output "name" {
  value = "${hcloud_server.server.name}"
}

output "ipv4_address" {
  value = "${hcloud_server.server.ipv4_address}"
}
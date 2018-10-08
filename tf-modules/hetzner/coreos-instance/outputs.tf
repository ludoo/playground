# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0

resource "null_resource" "server-list" {
  count = "${length(var.num_instances)}"

  triggers {
    id           = "${element(hcloud_server.server.*.id, count.index)}"
    name         = "${element(hcloud_server.server.*.name, count.index)}"
    ipv4_address = "${element(hcloud_server.server.*.ipv4_address, count.index)}"
  }
}

output "servers" {
  value = ["${null_resource.server-list.triggers}"]
}

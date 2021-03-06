# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0

output "instances" {
  value = ["${formatlist("id: %s, name: %s, ip: %s", hcloud_server.server.*.id, hcloud_server.server.*.name, hcloud_server.server.*.ipv4_address)}"]
}

output "ids" {
  value = ["${hcloud_server.server.*.id}"]
}

output "names" {
  value = ["${hcloud_server.server.*.name}"]
}

data "template_file" "trigger" {
  count    = "${var.num_instances}"
  template = "${lookup(null_resource.setup.*.triggers[count.index], "ipv4_address")}"
}

output "ipv4_addresses" {
  value = ["${data.template_file.trigger.*.rendered}"]
}

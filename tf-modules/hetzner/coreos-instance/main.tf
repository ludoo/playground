# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0
# heavy lifting from
# https://gist.github.com/thetechnick/12b33e4edfc96e4ccc9800afef2be7c5

data "template_file" "cloud-config" {
  count    = "${var.num_instances}"
  template = "${file("${path.module}/cloud-config.yaml")}"

  vars = {
    name         = "${element(hcloud_server.server.*.name, count.index)}"
    ssh_key      = "${file(var.ssh_public_key_file)}"
    ipv4_address = "${element(hcloud_server.server.*.ipv4_address, count.index)}"
  }
}

resource "hcloud_server" "server" {
  count = "${var.num_instances}"

  name        = "${var.name}${var.num_instances == 1 ? "" : format("-%02d", count.index)}"
  image       = "${var.source_image == "" ? "debian-9" : var.source_image}"
  server_type = "${var.type}"
  ssh_keys    = ["${var.ssh_public_key_id}"]
  datacenter  = "${var.datacenter}"
  rescue      = "${var.source_image == "" ? "linux64" : ""}"
}

resource "null_resource" "setup" {
  count = "${var.num_instances}"

  triggers {
    ipv4_address = "${ hcloud_server.server.*.ipv4_address[count.index] }"
  }

  connection {
    host        = "${element(hcloud_server.server.*.ipv4_address, count.index)}"
    timeout     = "2m"
    agent       = false
    private_key = "${file(var.ssh_private_key_file)}"
    user        = "${var.source_image == "" ? "root" : "core"}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.cloud-config.*.rendered, count.index)}"
    destination = "/${var.source_image == "" ? "root" : "home/core"}/cloud-config.yaml"
  }

  provisioner "remote-exec" {
    script = "${path.module}/${var.source_image == "" ? "install-from-scratch" : "install-from-image"}.sh"
  }

  provisioner "local-exec" {
    command = <<EOF
    ${
      var.source_image == ""
      ? "/bin/true"
      : "ssh -o 'StrictHostKeyChecking no' -i ${var.ssh_private_key_file} core@${element(hcloud_server.server.*.ipv4_address, count.index)} 'sudo bash -c \"(sleep 3 && reboot)&\"'"
    }
    EOF
  }
}

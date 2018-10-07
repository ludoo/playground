# Copyright 2018 Google LLC.
# SPDX-License-Identifier: Apache-2.0
# heavy lifting from
# https://gist.github.com/thetechnick/12b33e4edfc96e4ccc9800afef2be7c5

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yaml")}"

  vars = {
    name         = "${var.name}"
    ssh_key      = "${var.ssh_public_key}"
    ipv4_address = "${hcloud_server.server.ipv4_address}"
  }
}

resource "hcloud_server" "server" {
  name        = "${var.name}"
  image       = "${var.source_image == "" ? "debian-9" : var.source_image}"
  server_type = "${var.type}"
  ssh_keys    = ["${var.ssh_public_key_id}"]
  datacenter  = "${var.datacenter}"
  rescue      = "${var.source_image == "" ? "linux64" : ""}"
}

resource "null_resource" "coreos-install-from-scratch" {
  count      = "${var.source_image == "" ? 1 : 0}"
  depends_on = ["hcloud_server.server"]

  triggers {
    server_ip = "${hcloud_server.server.ipv4_address}"
  }

  connection {
    host        = "${hcloud_server.server.ipv4_address}"
    timeout     = "1m"
    agent       = false
    private_key = "${file(var.ssh_private_key_file)}"
  }

  provisioner "file" {
    content     = "${data.template_file.cloud-config.rendered}"
    destination = "/root/cloud-config.yaml"
  }

  provisioner "remote-exec" {
    script = "${path.module}/install-from-scratch.sh"
  }
}

resource "null_resource" "coreos-install-from-image" {
  count      = "${var.source_image == "" ? 0 : 1}"
  depends_on = ["hcloud_server.server"]

  triggers {
    server_ip = "${hcloud_server.server.ipv4_address}"
  }

  connection {
    host        = "${hcloud_server.server.ipv4_address}"
    timeout     = "1m"
    agent       = false
    private_key = "${file(var.ssh_private_key_file)}"
    user        = "core"
  }

  provisioner "file" {
    content     = "${data.template_file.cloud-config.rendered}"
    destination = "/home/core/cloud-config.yaml"
  }

  provisioner "remote-exec" {
    script = "${path.module}/install-from-image.sh"
  }

  provisioner "local-exec" {
    command = "ssh -o 'StrictHostKeyChecking no' -i ${var.ssh_private_key_file} core@${hcloud_server.server.ipv4_address} 'sudo bash -c \"(sleep 2 && reboot)&\"'"
  }
}

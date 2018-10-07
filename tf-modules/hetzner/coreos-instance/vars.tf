variable "name" {
  description = "Server name."
}

variable "ssh_public_key_id" {
  description = "ID of the SSH public key on Hetzner Cloud."
}

variable "ssh_public_key" {
  description = "Actual SSH public key matching the id on Hetzner Cloud"
}

variable "ssh_private_key_file" {
  description = "Private SSH key matching the public key on Hetzner Cloud"
}

variable "datacenter" {
  description = "Server datacenter"
  default     = "fsn1-dc8"
}

variable "type" {
  description = "Server type"
  default     = "cx11"
}

variable "source_image" {
  description = "CoreOS snapshot to use for faster instance creation."
  default     = ""
}

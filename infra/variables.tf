variable "prefix" { type = string }
variable "location" { type = string }
variable "vm_count" { type = number }
variable "admin_username" { type = string }
variable "ssh_public_key" { type = string }
variable "allow_ssh_from_cidr" { type = string }
variable "tags" { type = map(string) }


prefix = "lab8"
location = "eastus"
vm_count = 2
admin_username = "danielPatinoAzure"
ssh_public_key = "~/.ssh/id_ed25519.pub"
allow_ssh_from_cidr = "192.168.2.3/32"
tags = {
    owner = "danielpm",
    course = "ARSW",
    env = "dev",
    expieres = "2026-12-31"
}

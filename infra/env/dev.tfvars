prefix              = "lab8"
location            = "eastus"
vm_count            = 2
admin_username      = "daniel"
ssh_public_key      = "~/.ssh/id_ed25519.pub"
allow_ssh_from_cidr = "192.168.2.4/32" # Cambia a tu IP/32
tags                = { owner = "daniel-pm19", course = "ARSW", env = "dev", expires = "2026-12-31" }

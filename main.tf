{fileheader}
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">=2.9.3"
    }
/*
      other = {
      source = "dev/other"
      version = ""
    }
*/
  }
}

provider "proxmox" {
  // pm_user = "" # Use shell vars instead
  // export PM_USER="terraform-user@pve"
  // export PM_PASS="password"
  pm_api_url = "https://yourserver:8006/api2/json"
  pm_tls_insecure = "true"
  pm_log_enable = "true"
  pm_log_file = "terraform-plugin-proxmox.log"
  }
  
  variable "host_name" {
  description = "LXC container hostname"
  type = string
  default = "Host2"
// sensitive = true #this means, that you will store the values in .tfvars file and run terraform with -var-file=keys.tfvars ; default value must be removed
}
resource "proxmox_vm_qemu" "proxmox_vm" {
  vmid = 111 # remove the line, for auto adjust (first available ID)
  name              = "Host1"
  target_node       = "pve"
  clone              = "ubuntu-template"
  agent             = 1
  os_type           = "ubuntu"
  cores             = 1
  sockets           = 1
  cpu               = "host"
  memory            = 512
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  ci_wait           = 60
 disk {
    size            = "8G"
    type            = "scsi"
    storage         = "local-lvm"
  }
network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

# Cloud Init
  ciuser = "user"
  ipconfig0 = "ip=dhcp"
  sshkeys = <<EOF
 ssh-rsa AAAAA .... public@key
EOF

}

output "ip_address" {
  value = "${proxmox_vm_qemu.proxmox_vm.default_ipv4_address}"
}

# Create Container
resource "proxmox_lxc" "terraform_lxc" {
  vmid = 222
  target_node  = "pve"
  hostname     = "${var.host_name}"
  ostemplate   = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  unprivileged = true
  ostype = "ubuntu"  
  start = true
  ssh_public_keys = <<EOF
 ssh-rsa AAAAA .... public@key
EOF

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.0.0.2/8"
    gw = "10.0.0.1"
  }
}

output "ip_address" {
	value = "${proxmox_lxc.terraform_lxc.network[0].ip}"
	}

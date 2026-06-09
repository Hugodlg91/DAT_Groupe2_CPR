resource "proxmox_virtual_environment_vm" "srv_wazuh" {
  node_name = "pve"
  name      = "SRV-WAZUH"
  vm_id     = 102

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  cdrom {
    file_id   = "local:iso/ubuntu-26.04-live-server-amd64.iso"
    interface = "ide0"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 80
    interface    = "virtio0"
    discard      = "on"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  boot_order = ["ide0", "virtio0"]
  started    = false
}

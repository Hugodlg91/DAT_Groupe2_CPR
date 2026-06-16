resource "proxmox_virtual_environment_vm" "srv_zabbix" {
  node_name = "pve"
  name      = "SRV-ZABBIX"
  vm_id     = 107

  bios            = "seabios"
  keyboard_layout = "fr"
  on_boot         = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  cdrom {
    file_id   = "local:iso/ubuntu-26.04-live-server-amd64.iso"
    interface = "ide0"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "virtio0"
    discard      = "on"
    aio          = "io_uring"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  boot_order = ["ide0", "virtio0"]
  started    = false
}

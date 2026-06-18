resource "proxmox_virtual_environment_vm" "srv_ad01" {
  node_name = "pve"
  name      = "SRV-AD01"
  vm_id     = 101

  bios            = "seabios"
  keyboard_layout = "fr"
  on_boot         = true

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 10528
  }

  disk {
    datastore_id = "local-lvm"
    size         = 60
    interface    = "virtio0"
    discard      = "on"
    aio          = "io_uring"
  }

  cdrom {
    file_id   = "local:iso/virtio-win.iso"
    interface = "ide1"
  }

  network_device {
    bridge      = "vmbr2"
    model       = "virtio"
    mac_address = "BC:24:11:19:1A:38"
  }

  boot_order = ["virtio0", "ide1"]
  started    = true
}

resource "proxmox_virtual_environment_vm" "opnsense" {
  node_name = "pve"
  name      = "FW-OPN01"
  vm_id     = 100

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

  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "virtio0"
    discard      = "on"
    aio          = "io_uring"
  }

  network_device {
    bridge      = "vmbr0"
    model       = "virtio"
    mac_address = "BC:24:11:43:F2:D1"
  }

  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:A0:34:63"
  }

  network_device {
    bridge      = "vmbr2"
    model       = "virtio"
    mac_address = "BC:24:11:48:92:63"
  }

  network_device {
    bridge      = "vmbr3"
    model       = "virtio"
    mac_address = "BC:24:11:C5:3F:F5"
  }

  network_device {
    bridge      = "vmbr4"
    model       = "virtio"
    mac_address = "BC:24:11:52:A1:AB"
  }

  boot_order = ["virtio0"]
  started    = true
}

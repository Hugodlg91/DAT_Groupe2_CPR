resource "proxmox_virtual_environment_vm" "srv_dmz" {
  node_name = "pve"
  name      = "SRV-DMZ"
  vm_id     = 105

  bios            = "seabios"
  keyboard_layout = "fr"
  on_boot         = true

  cpu {
    cores   = 1
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "virtio0"
    discard      = "on"
    aio          = "io_uring"
  }

  network_device {
    bridge      = "vmbr4"
    model       = "virtio"
    mac_address = "BC:24:11:28:22:90"
  }

  boot_order = ["virtio0"]
  started    = true
}

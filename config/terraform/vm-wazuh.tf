resource "proxmox_virtual_environment_vm" "srv_wazuh" {
  node_name = "pve"
  name      = "SRV-WAZUH"
  vm_id     = 102

  bios            = "seabios"
  keyboard_layout = "fr"
  on_boot         = true

  cpu {
    cores   = 4
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-lvm"
    size         = 80
    interface    = "virtio0"
    discard      = "on"
    aio          = "io_uring"
  }

  network_device {
    bridge      = "vmbr2"
    model       = "virtio"
    mac_address = "BC:24:11:10:8A:E4"
  }

  boot_order = ["virtio0"]
  started    = true
}

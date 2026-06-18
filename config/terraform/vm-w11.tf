resource "proxmox_virtual_environment_vm" "clt_w11" {
  node_name = "pve"
  name      = "CLT-W11"
  vm_id     = 103

  bios            = "ovmf"
  machine         = "q35"
  keyboard_layout = "fr"
  on_boot         = true

  cpu {
    cores   = 2
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated = 8192
  }

  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = true
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
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "BC:24:11:D9:83:DD"
  }

  boot_order = ["virtio0", "ide1"]
  started    = true
}

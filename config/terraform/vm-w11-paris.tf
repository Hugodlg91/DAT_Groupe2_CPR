resource "proxmox_virtual_environment_vm" "clt_w11_paris" {
  node_name = "pve"
  name      = "CLT-W11-PARIS"
  vm_id     = 104

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
    dedicated = 10560
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
    interface = "ide2"
  }

  network_device {
    bridge      = "vmbr3"
    model       = "virtio"
    mac_address = "BC:24:11:21:ED:61"
  }

  boot_order = ["virtio0", "ide2"]
  started    = true
}

resource "proxmox_virtual_environment_vm" "srv_ad01" {
  node_name = "pve"
  name      = "SRV-AD01"
  vm_id     = 101

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  cdrom {
    file_id   = "local:iso/windows-server-2022-eval.iso"
    interface = "ide0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/virtio-win.iso"
    interface    = "ide1"
    size         = 8
  }

  disk {
    datastore_id = "local-lvm"
    size         = 60
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

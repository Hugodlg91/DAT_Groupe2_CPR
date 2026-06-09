resource "proxmox_virtual_environment_vm" "opnsense" {
  node_name = "pve"
  name      = "FW-OPN01"
  vm_id     = 100

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  cdrom {
    file_id   = "local:iso/OPNsense-26.1-dvd-amd64.iso"
    interface = "ide0"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 20
    interface    = "virtio0"
    discard      = "on"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr3"
    model  = "virtio"
  }

  network_device {
    bridge = "vmbr4"
    model  = "virtio"
  }

  boot_order = ["ide0", "virtio0"]
  started    = false
}

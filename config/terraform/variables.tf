variable "proxmox_api_url" {
  default = "https://192.168.1.160:8006/api2/json"
}

variable "proxmox_token_id" {
  description = "Token ID Proxmox - définir via TF_VAR_proxmox_token_id"
  sensitive   = true
}

variable "proxmox_token_secret" {
  description = "Token Secret Proxmox - définir via TF_VAR_proxmox_token_secret"
  sensitive   = true
}

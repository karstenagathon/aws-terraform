variable "bastion_state_path" {
  description = "Path to bastion root terraform.tfstate (local backend)"
  type        = string
  default     = "../bastion/terraform.tfstate"
}

variable "resource_server_state_path" {
  description = "Path to resource-server root terraform.tfstate (local backend)"
  type        = string
  default     = "../resource-server/terraform.tfstate"
}

variable "default_tags" {
  description = "Default tags applied to supported resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Stack     = "sandbox-2-resource-server"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox-2"
}

variable "aws_profile" {
  description = "AWS profile for credentials."
  type        = string
}

variable "server_instance_type" {
  description = "Instance type for resource server"
  type        = string
  default     = "t3.micro"
}

variable "infra_state_path" {
  description = "Path to infra state file (local backend)"
  type        = string
  default     = "../infra/terraform.tfstate"
}

variable "bastion_state_path" {
  description = "Path to bastion state file (local backend)"
  type        = string
  default     = "../bastion/terraform.tfstate"
}

variable "default_tags" {
  description = "Default tags applied to supported resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Stack     = "sandbox-2"
  }
}
variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_id" {
  description = "AWS account ID for sandbox-2"
  type        = string
  default     = "099296998251"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["ap-southeast-1a"]
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication."
  type        = string
}

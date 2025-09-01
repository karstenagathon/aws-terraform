variable "default_tags" {
  description = "Default tags applied to supported resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Stack     = "org-management"
  }
}

variable "aws_profile" {
  description = "AWS profile to use for authentication."
  type        = string
}

variable "aws_accounts" {
  description = "Accounts to create under the org."
  type = map(object({
    name     = string
    email    = string
  }))
}


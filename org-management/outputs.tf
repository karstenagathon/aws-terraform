output "account_id" {
  description = "AWS Account ID used by this identity root."
  value       = data.aws_caller_identity.current.account_id
}

output "accounts" {
  description = "List of all AWS accounts created in the organization"
  value       = var.aws_accounts
}

output "identity_group_id" {
  description = "The ID of the Identity Center admin group created."
  value       = aws_identitystore_group.admin.group_id
}

output "admin_permission_set_arn" {
  description = "The ARN of the administrator permission set."
  value       = data.aws_ssoadmin_permission_set.admin.arn
}


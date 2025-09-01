# Data sources useful for outputs and conditional logic.
data "aws_caller_identity" "current" {}

# Identity Center (SSO) instance info: get instance ARN and Identity Store ID.
data "aws_ssoadmin_instances" "sso" {}

data "aws_organizations_organization" "current" {}

# Create a group in IAM Identity Center.
resource "aws_identitystore_group" "admin" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  display_name = "admin"
  description  = "Admin group with full access to AWS accounts"
}

resource "aws_organizations_account" "accounts" {
  for_each  = var.aws_accounts

  name      = each.value.name
  email     = each.value.email
  lifecycle { prevent_destroy = true }
}

# # Create a permission set with administrator access for the admin group.
# resource "aws_ssoadmin_permission_set" "admin" {
#   instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
#
#   name        = "AdministratorAccess"
#   description = "Full administrator access to AWS accounts"
# }
#
# # Attach the AWS managed AdministratorAccess policy to the permission set.
# resource "aws_ssoadmin_managed_policy_attachment" "admin" {
#   instance_arn       = aws_ssoadmin_permission_set.admin.instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.admin.arn
#   managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# Import existing AdministratorAccess permission set instead of creating new one.
data "aws_ssoadmin_permission_set" "admin" {
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  name = "AdministratorAccess"
}

# Assign the admin group to all accounts except the management and suspended accounts
resource "aws_ssoadmin_account_assignment" "admin" {
  for_each = toset([
    for account_id in data.aws_organizations_organization.current.accounts[*].id :
    account_id if !contains(["283128590419", "410403517673"], account_id)
  ])

  instance_arn       = data.aws_ssoadmin_permission_set.admin.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_group.admin.group_id
  principal_type = "GROUP"

  target_id   = each.value
  target_type = "AWS_ACCOUNT"
}

# Read existing user karsten.agathon from Identity Center.
data "aws_identitystore_user" "karsten_agathon" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "karsten.agathon"
    }
  }
}

# Add existing karsten.agathon user to the admin group.
resource "aws_identitystore_group_membership" "admin_karsten" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  group_id          = aws_identitystore_group.admin.group_id
  member_id         = data.aws_identitystore_user.karsten_agathon.user_id
}


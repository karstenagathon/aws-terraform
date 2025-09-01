data "terraform_remote_state" "bastion" {
  backend = "local"
  config = {
    path = var.bastion_state_path
  }
}

data "terraform_remote_state" "resource" {
  backend = "local"
  config = {
    path = var.resource_server_state_path
  }
}

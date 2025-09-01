# Inventory with SSH proxy through bastion
resource "local_file" "hosts_ini" {
  filename = "${path.module}/hosts.ini"
  content  = <<-INI
  [bastion_host]
  bastion ansible_host=${data.terraform_remote_state.bastion.outputs.bastion_public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${replace(data.terraform_remote_state.bastion.outputs.private_key_filename, "./", "../bastion/")}

  [resource_server]
  server ansible_host=${data.terraform_remote_state.resource.outputs.server_private_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${replace(data.terraform_remote_state.resource.outputs.private_key_filename, "./", "../resource-server/")} ansible_ssh_common_args='-o ProxyJump=ec2-user@${data.terraform_remote_state.bastion.outputs.bastion_public_ip} -o StrictHostKeyChecking=accept-new'
  INI
}

# Ansible configuration
resource "local_file" "ansible_cfg" {
  filename = "${path.module}/ansible.cfg"
  content  = <<-CFG
  [defaults]
  inventory = ${path.module}/hosts.ini
  host_key_checking = False
  forks = 10
  timeout = 30
  interpreter_python = auto_silent

  [ssh_connection]
  pipelining = True
  ssh_args = -o ControlMaster=auto -o ControlPersist=60s
  CFG
}

# Sample playbook to validate connectivity
resource "local_file" "ping_playbook" {
  filename = "${path.module}/ping.yml"
  content  = <<-YML
  ---
  - name: Ping bastion and resource server
    hosts: all
    gather_facts: false
    tasks:
      - name: Ping
        ansible.builtin.ping:
  YML
}

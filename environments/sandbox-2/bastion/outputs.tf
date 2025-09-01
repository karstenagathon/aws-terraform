output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Security group ID for bastion"
  value       = module.bastion_sg.security_group_id
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = aws_key_pair.bastion_keypair.key_name
}

output "private_key_filename" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "SSH command to connect to the bastion host"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${module.bastion.public_ip}"
}

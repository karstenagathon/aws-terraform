output "server_private_ip" {
  description = "Private IP of the resource server"
  value       = module.server.private_ip != null ? module.server.private_ip : ""
}

output "server_security_group_id" {
  description = "Security group ID for resource server"
  value       = module.server_sg.security_group_id
}

output "key_pair_name" {
  description = "Name of the generated key pair"
  value       = aws_key_pair.server_keypair.key_name
}

output "private_key_filename" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "SSH command to connect to the resource server host via private ip"
  value       = module.server.private_ip != null ? "ssh -i ${local_file.private_key.filename} ec2-user@${module.server.private_ip}" : "Server instance is disabled"
}
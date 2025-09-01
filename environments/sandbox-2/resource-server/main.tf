resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "server_keypair" {
  key_name   = "${var.environment}-server-key"
  public_key = tls_private_key.server_key.public_key_openssh

  tags = merge(var.default_tags, {
    Name = "${var.environment}-server-key"
  })
}

resource "local_file" "private_key" {
  content         = tls_private_key.server_key.private_key_pem
  filename        = "${path.module}/${var.environment}-server-key.pem"
  file_permission = "0400"
}

module "server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.environment}-server-sg"
  description = "Security group for resource server"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "SSH from bastion"
      source_security_group_id = data.terraform_remote_state.bastion.outputs.bastion_security_group_id
    },
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "HTTP from bastion"
      source_security_group_id = data.terraform_remote_state.bastion.outputs.bastion_security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All outbound"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.default_tags
}

module "server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = "${var.environment}-server"

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.server_instance_type
  key_name               = aws_key_pair.server_keypair.key_name
  subnet_id              = data.terraform_remote_state.infra.outputs.private_subnet_id
  vpc_security_group_ids = [module.server_sg.security_group_id]
  monitoring             = false
  user_data_replace_on_change = true

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              set -euo pipefail
              exec > >(tee /var/log/user-data.log) 2>&1
              echo "Starting user-data script..."

              # Use dnf for Amazon Linux 2023 (AL2023)
              dnf update -y
              dnf install -y httpd htop tree

              # Start and enable httpd
              systemctl enable httpd
              systemctl start httpd

              # Create index page
              echo "<h1>Resource Server - ${var.environment}</h1>" > /var/www/html/index.html
              echo "<p>Server started at: $(date)</p>" >> /var/www/html/index.html

              # Set proper permissions
              chown apache:apache /var/www/html/index.html

              echo "User-data script completed successfully"
              EOF
  )

  tags = merge(var.default_tags, { Role = "application" })
}

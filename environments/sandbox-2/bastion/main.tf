resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "${var.environment}-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh

  tags = merge(var.default_tags, {
    Name = "${var.environment}-bastion-key"
  })
}

resource "local_file" "private_key" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "${path.module}/${var.environment}-bastion-key.pem"
  file_permission = "0400"
}

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from allowed CIDR"
      cidr_blocks = var.allowed_ssh_cidr
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

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.0"

  name = "${var.environment}-bastion"

  ami                          = data.aws_ami.amazon_linux.id
  instance_type                = var.bastion_instance_type
  key_name                     = aws_key_pair.bastion_keypair.key_name
  subnet_id                    = data.terraform_remote_state.infra.outputs.public_subnet_id
  vpc_security_group_ids       = [module.bastion_sg.security_group_id]
  associate_public_ip_address  = true
  monitoring                   = false
  user_data_replace_on_change = true

  user_data_base64 = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y htop tree
              echo "Bastion host ready" > /tmp/bastion-ready
              EOF
  )

  tags = merge(var.default_tags, { Role = "bastion" })
}

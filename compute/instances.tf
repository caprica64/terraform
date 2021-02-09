resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "myKeyPair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.tls_connector.public_key_openssh
}

data "aws_ami" "linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20191116.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_instance" "BastionHost" {
  ami           = data.aws_ami.linux2.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = [var.BastionSG]
  subnet_id     = var.publicSubnetA

  tags = {
    Name = "BastionHost"
  }
}

resource "local_file" "myLabKeyPairFile" {
    content     = tls_private_key.tls_connector.private_key_pem
    filename    = "myLabKeyPair.pem"
}

locals {
  pub_file_path = "/Users/sabyrzhan/.ssh/id_ecdsa.pub"
  user_data = <<-EOF
              #!/bin/bash
              echo "${file(local.pub_file_path)}" >> /home/admin/.ssh/authorized_keys
              EOF
}

data "aws_ami" "debian" {
  most_recent = true
  owners = ["136693071363"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "name"
    values = ["debian-12-arm64-*"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API from anywhere"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jumpbox" {
  ami = data.aws_ami.debian.id
  security_groups = [ aws_security_group.allow_ssh.name ]
  instance_type = "t4g.small"
  availability_zone = "eu-central-1a"
  root_block_device {
    volume_size = 10
  }

  user_data = format(local.user_data)
}

resource "aws_instance" "server" {
  ami = data.aws_ami.debian.id
  security_groups = [ aws_security_group.allow_ssh.name ]
  instance_type = "t4g.small"
  availability_zone = "eu-central-1a"
  root_block_device {
    volume_size = 20
  }

  user_data = format(local.user_data)
}

resource "aws_instance" "node-0" {
  ami = data.aws_ami.debian.id
  security_groups = [ aws_security_group.allow_ssh.name ]
  instance_type = "t4g.small"
  availability_zone = "eu-central-1a"
  root_block_device {
    volume_size = 20
  }

  user_data = format(local.user_data)
}

resource "aws_instance" "node-1" {
  ami = data.aws_ami.debian.id
  security_groups = [ aws_security_group.allow_ssh.name ]
  instance_type = "t4g.small"
  availability_zone = "eu-central-1a"
  root_block_device {
    volume_size = 20
  }

  user_data = format(local.user_data)
}

output "jumpbox_ip" {
  value = "${aws_instance.jumpbox.public_ip}/${aws_instance.jumpbox.private_ip}"
}

output "server_ip" {
  value = "${aws_instance.server.public_ip}/${aws_instance.server.private_ip}"
}

output "node0_ip" {
  value = "${aws_instance.node-0.public_ip}/${aws_instance.node-0.private_ip}"
}

output "node1_ip" {
  value = "${aws_instance.node-1.public_ip}/${aws_instance.node-1.private_ip}"
}
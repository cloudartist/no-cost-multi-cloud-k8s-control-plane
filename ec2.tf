module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "k8s-control-plane"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.deployer.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_all_for_dev.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  user_data_base64 = filebase64("${path.module}/files/k8s-cluster-install.sh")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "allow_all_for_dev" {
  name        = "allow_all_for_dev"
  description = "Allow all inbound traffic from developers workstation"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_traffic_for_dev" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${data.external.myipaddr.result.ip}/32"]
  security_group_id = aws_security_group.allow_all_for_dev.id
}

resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.allow_all_for_dev.id
  cidr_blocks       = ["0.0.0.0/0"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "k8s"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
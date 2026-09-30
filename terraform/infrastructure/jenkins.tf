data "aws_ssm_parameter" "tc2_jenkins_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "tc2_jenkins" {
  name = "tech-challenge-2-jenkins"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tc2_jenkins_ssm" {
  role       = aws_iam_role.tc2_jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "tc2_jenkins" {
  name = "tech-challenge-2-jenkins"
  role = aws_iam_role.tc2_jenkins.name
}

resource "aws_security_group" "tc2_jenkins" {
  name_prefix = "tc2-jenkins-"
  description = "Jenkins server accessed through Systems Manager"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "tech-challenge-2-jenkins"
  }
}

resource "aws_vpc_security_group_egress_rule" "tc2_jenkins_outbound" {
  security_group_id = aws_security_group.tc2_jenkins.id
  description       = "Outbound access for packages and AWS services"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "tc2_jenkins" {
  ami                         = data.aws_ssm_parameter.tc2_jenkins_ami.value
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.tc2_jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.tc2_jenkins.name

  user_data                   = file("${path.module}/jenkins-user-data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [
    aws_iam_role_policy_attachment.tc2_jenkins_ssm,
    aws_vpc_security_group_egress_rule.tc2_jenkins_outbound,
    module.vpc
  ]

  tags = {
    Name = "tech-challenge-2-jenkins"
  }
}

output "jenkins_instance_id" {
  value = aws_instance.tc2_jenkins.id
}

output "jenkins_private_ip" {
  value = aws_instance.tc2_jenkins.private_ip
}

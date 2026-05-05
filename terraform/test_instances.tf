#############################################
# Test EC2 Instances for traffic testing
# Use SSM Session Manager (no SSH key needed)
#############################################

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name_prefix = "${var.project_name}-ssm-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name_prefix = "${var.project_name}-ssm-"
  role        = aws_iam_role.ssm_role.name
}

# Security Group for test instances
resource "aws_security_group" "test_dev" {
  name_prefix = "${var.project_name}-test-dev-"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-Test-DEV-SG" }
}

resource "aws_security_group" "test_prd" {
  name_prefix = "${var.project_name}-test-prd-"
  vpc_id      = aws_vpc.prd.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-Test-PRD-SG" }
}

# DEV Test Instance
resource "aws_instance" "test_dev" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev_app_b.id
  vpc_security_group_ids = [aws_security_group.test_dev.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  tags = { Name = "${var.project_name}-Test-DEV-EC2" }
}

# PRD Test Instance
resource "aws_instance" "test_prd" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.prd_app_b.id
  vpc_security_group_ids = [aws_security_group.test_prd.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF

  tags = { Name = "${var.project_name}-Test-PRD-EC2" }
}

#############################################
# Outputs for testing
#############################################
output "test_dev_instance_id" {
  value = aws_instance.test_dev.id
}

output "test_dev_private_ip" {
  value = aws_instance.test_dev.private_ip
}

output "test_prd_instance_id" {
  value = aws_instance.test_prd.id
}

output "test_prd_private_ip" {
  value = aws_instance.test_prd.private_ip
}

output "sdwan_frr_private_ip" {
  value = aws_instance.sdwan_frr.private_ip
}

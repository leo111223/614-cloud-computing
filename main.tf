# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "LEO_AWS_KEY"   # SSH key pair name for EC2 instance access
}

resource "aws_security_group" "public_access" {
  name_prefix = "public_access_sg"

  # Ingress rules: Allow SSH and HTTP traffic from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs for SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs for HTTP
  }

  # Egress rules: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-access-sg"
  }
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
  ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
  instance_type = var.instance_type            # Use the instance type from variables
  key_name      = "${local.aws_key}"          # Specify the SSH key pair name

   
  vpc_security_group_ids = [aws_security_group.public_access.id] # Associate the security group
  user_data = file("wp_install.sh") # Run WordPress install script automatically on instance launch
   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }                  
}
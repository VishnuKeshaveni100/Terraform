resource "aws_instance" "ec2s3" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    count = 1
    tags {
      Name = "ec2s3"
    }
}

resource "aws_security_group" "onesec" {
    name        = "onesec"
    description = "to allow the inbound traffic"
    vpc_id = var.vpc_id

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onesec"
  }
} 

# Create an IAM role for the ec2 instance.
resource "aws_iam_role" "ec2_s3_iam_role" {
    name = "ec2_s3_iam_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
EOF
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
  name = "web_iam_role_policy"
  role = aws_iam_role.web_iam_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
EOF
}

resource "iam_role_policy_attachment" "role-policy-attachment" {
    name = "role-policy"
    roles      = aws_iam_role.ec2_s3_iam_role.name
}

resource "aws_iam_instance_profile" "test_profile" {
  name  = "test"
  roles = aws_iam_role.ec2_s3_iam_role.name
}

resource "aws_s3_bucket" "test_bucket" {
    bucket = "one-bucket"
    versioning {
            enabled = false
    }
    tags {
        Name = "one-bucket"
    }
}
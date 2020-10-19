provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_policy" "policy" {
  name        = "WebAppS3"
  path        = "/"
  description = "allow EC2 instances to perform S3 buckets"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::webapp.jing.zhang",
                "arn:aws:s3:::webapp.jing.zhang/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "role" {
  name = "EC2-CSYE6225"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

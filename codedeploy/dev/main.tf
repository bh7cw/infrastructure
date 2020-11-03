module "services" {
  source = "../../modules/services"

  hostedzone_zone_id = "Z09857512143LTLIXWAC5"
  dns_a_record_name = "api.dev.bh7cw.me."
  aws_iam_gh-code-deploy-policy_content = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:us-east-1:918834676735:application:csye6225-webapp"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF

  aws_iam_codedeploy_ec2_s3_policy_content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:s3:::codedeploy.dev.bh7cw.me",
              "arn:aws:s3:::codedeploy.dev.bh7cw.me/*"
            ]
        }
    ]
}
EOF

  aws_iam_gh_upload_to_s3_policy_content = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::codedeploy.dev.bh7cw.me",
                "arn:aws:s3:::codedeploy.dev.bh7cw.me/*"
            ]
        }
    ]
}
EOF
}
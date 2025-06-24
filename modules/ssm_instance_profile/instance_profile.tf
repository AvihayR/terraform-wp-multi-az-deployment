resource "aws_iam_role" "wp_ec2_role" {
  name = "wordpress-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_read" {
  name = "Read_SSM_WordPress_secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = "arn:aws:ssm:*:*:parameter/wordpress/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wp_ec2_ssm_read_attachment" {
  role       = aws_iam_role.wp_ec2_role.name
  policy_arn = aws_iam_policy.ssm_read.arn
}

resource "aws_iam_instance_profile" "wp_ssm_profile" {
  name = "wp_ssm_profile"
  role = aws_iam_role.wp_ec2_role.name
}

output "name" {
  value = aws_iam_instance_profile.wp_ssm_profile.name
}
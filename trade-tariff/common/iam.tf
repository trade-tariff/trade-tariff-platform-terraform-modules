resource "aws_iam_access_key" "service-account" {
  user = aws_iam_user.service-account.name
}

resource "aws_iam_user" "service-account" {
  name = "trade-tariff-service-account"
  path = "/system/"
}

resource "aws_iam_access_key" "ci-account" {
  user = aws_iam_user.ci-account.name
}

resource "aws_iam_user" "ci-account" {
  name = "trade-tariff-ci-account"
  path = "/system/"
}

resource "aws_iam_access_key" "dit-database-backups-account" {
  user = aws_iam_user.dit-database-backups-account.name
}

resource "aws_iam_user" "dit-database-backups-account" {
  name = "trade-tariff-dit-database-backups"
  path = "/customer/"
}

resource "aws_iam_role" "ecr_access" {
  name = "ci-role"

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


resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr-policy"
  description = "ECR policy for managing project deployment ECR images"

  policy = data.aws_iam_policy_document.ecr.json
}

data "aws_iam_policy_document" "ecr" {
  statement {
    sid = "VisualEditor0"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      "ecr:PutImage",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:PutLifecyclePolicy",
      "ecr:StartImageScan",
      "ecr:StartLifecyclePolicyPreview",
      "ecr:TagResource",
      "ecr:UploadLayerPart",
    ]

    resources = [
      "arn:aws:ecr:eu-west-2:777015734912:repository/*"
    ]
  }

  statement {
    sid = "VisualEditor1"
    actions = [
      "ecr:DescribeRegistry",
      "ecr:GetAuthorizationToken",
      "ecr:GetRegistryPolicy",
      "ecr:PutRegistryPolicy",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "es_policy" {
  name        = "es-policy"
  description = "ES policy for custom package lifecycle management"

  policy = data.aws_iam_policy_document.es.json
}

data "aws_iam_policy_document" "es" {
  statement {
    sid = ""

    actions = [
      "es:DescribePackages",
      "es:UpdatePackage",
    ]

    resources = ["*"]
  }

  statement {
    sid = ""

    actions = ["es:AssociatePackage"]

    resources = [
      "arn:aws:es:eu-west-2:777015734912:domain/tariff-search-development",
      "arn:aws:es:eu-west-2:777015734912:domain/tariff-search-staging",
      "arn:aws:es:eu-west-2:777015734912:domain/tariff-search-production",
    ]
  }
}

resource "aws_iam_policy" "ses_policy" {
  name        = "ses-policy"
  description = "SES policy for users to send mail using SES"

  policy = data.aws_iam_policy_document.ses.json
}

data "aws_iam_policy_document" "ses" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_user_policy_attachment" "ci-ses" {
  user       = aws_iam_user.ci-account.name
  policy_arn = aws_iam_policy.ses_policy.arn
}

resource "aws_iam_user_policy_attachment" "ci-ecr" {
  user       = aws_iam_user.ci-account.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_user_policy_attachment" "ci-es" {
  user       = aws_iam_user.ci-account.name
  policy_arn = aws_iam_policy.es_policy.arn
}


output "service_iam_id" {
  value = aws_iam_access_key.service-account.id
}

output "service_secret" {
  value     = aws_iam_access_key.service-account.secret
  sensitive = true
}

output "ci_iam_id" {
  value = aws_iam_access_key.service-account.id
}

output "ci_secret" {
  value     = aws_iam_access_key.service-account.secret
  sensitive = true
}

locals {
  ci-account-s3-policies = [
    "reporting",
    "search-configuration",
    "opensearch-package",
    "database-backups",
  ]
  service-account-s3-policies = [
    "persistence",
    "search-configuration",
    "opensearch-package",
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "reporting" {
  bucket = "${var.project-key}-reporting"
  acl    = "private"

  tags = {
    Project = var.project-key
  }
}

resource "aws_s3_bucket" "database-backups" {
  bucket = "${var.project-key}-database-backups"
  acl    = "private"

  tags = {
    Project = var.project-key
  }
}

resource "aws_s3_bucket" "persistence" {
  count = length(var.environments)

  bucket = "${var.project-key}-persistence-${var.environments[count.index]}"
  acl    = "private"

  tags = {
    Project     = var.project-key
    Environment = element(var.environments, count.index)
  }
}

resource "aws_s3_bucket" "opensearch_packages" {
  count = length(var.environments)

  bucket = "${var.project-key}-opensearch-packages-${var.environments[count.index]}"
  acl    = "private"

  tags = {
    Project     = var.project-key
    Environment = element(var.environments, count.index)
  }
}

resource "aws_s3_bucket" "search_configuration" {
  count = length(var.environments)

  bucket = "${var.project-key}-search-configuration-${var.environments[count.index]}"
  acl    = "private"

  tags = {
    Project     = var.project-key
    Environment = element(var.environments, count.index)
  }
}

resource "aws_s3_bucket_public_access_block" "reporting" {
  bucket = aws_s3_bucket.reporting.id

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_public_access_block" "database-backups" {
  bucket = aws_s3_bucket.database-backups.id

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_public_access_block" "persistence" {
  count  = length(aws_s3_bucket.persistence)
  bucket = aws_s3_bucket.persistence.*.id[count.index]

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_public_access_block" "opensearch-packages" {
  count  = length(aws_s3_bucket.opensearch_packages)
  bucket = aws_s3_bucket.opensearch_packages.*.id[count.index]

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_public_access_block" "search-configuration" {
  count  = length(aws_s3_bucket.search_configuration)
  bucket = aws_s3_bucket.search_configuration.*.id[count.index]

  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_iam_policy" "persistence" {
  name        = "persistence-read-write"
  description = "Provides read and write access to all persistence buckets that are used for storing ETL files."
  policy      = data.aws_iam_policy_document.s3-persistence-policy.json
}

resource "aws_iam_policy" "reporting" {
  name        = "reporting-read-write"
  description = "Provides read and write access to the generic reporting bucket."
  policy      = data.aws_iam_policy_document.s3-reporting-policy.json
}

resource "aws_iam_policy" "database-backups-read" {
  name        = "database-backups-read"
  description = "Enables reading database backups"
  policy      = data.aws_iam_policy_document.s3-database-backups-read-policy.json
}

resource "aws_iam_policy" "database-backups-read-write" {
  name        = "database-backups-read-write"
  description = "Enables reading and writing database backups"
  policy      = data.aws_iam_policy_document.s3-database-backups-read-write-policy.json
}


resource "aws_iam_policy" "opensearch-package" {
  name        = "opensearch-package-read-write"
  description = "Provides read and write access to manage opensearch synonym packages"
  policy      = data.aws_iam_policy_document.s3-search-package-policy.json
}

resource "aws_iam_policy" "search-configuration" {
  name        = "search-configuration-read-write"
  description = "Provides read and write access to manage search configuration fixtures - especially those used for search query parsing/spelling corrections, etc."
  policy      = data.aws_iam_policy_document.s3-search-configuration-policy.json
}

data "aws_iam_policy_document" "s3-reporting-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-reporting",
      "arn:aws:s3:::trade-tariff-reporting/*",
    ]
  }

  statement {
    actions = [
      "s3:AbortUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListUploadParts",
      "s3:ListObjectsV2",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-reporting",
      "arn:aws:s3:::trade-tariff-reporting/*",
    ]
  }
}

data "aws_iam_policy_document" "s3-database-backups-read-write-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-database-backups",
      "arn:aws:s3:::trade-tariff-database-backups/*",
    ]
  }

  statement {
    actions = [
      "s3:AbortUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListUploadParts",
      "s3:ListObjectsV2",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-database-backups",
      "arn:aws:s3:::trade-tariff-database-backups/*",
    ]
  }
}

data "aws_iam_policy_document" "s3-database-backups-read-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-database-backups",
      "arn:aws:s3:::trade-tariff-database-backups/*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListUploadParts",
      "s3:ListObjectsV2",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-database-backups",
      "arn:aws:s3:::trade-tariff-database-backups/*",
    ]
  }
}

data "aws_iam_policy_document" "s3-persistence-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-persistence-*/*",
      "arn:aws:s3:::trade-tariff-persistence-*",
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-persistence-*/*",
      "arn:aws:s3:::trade-tariff-persistence-*",
    ]
  }
}

data "aws_iam_policy_document" "s3-search-package-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-opensearch-packages-*",
      "arn:aws:s3:::trade-tariff-opensearch-packages-*/*",
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-opensearch-packages-*",
      "arn:aws:s3:::trade-tariff-opensearch-packages-*/*",
    ]
  }
}

data "aws_iam_policy_document" "s3-search-configuration-policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = [
      "arn:aws:s3:::trade-tariff-search-configuration-*",
      "arn:aws:s3:::trade-tariff-search-configuration-*/*",
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "arn:aws:s3:::trade-tariff-search-configuration-*",
      "arn:aws:s3:::trade-tariff-search-configuration-*/*",
    ]
  }
}

resource "aws_iam_user_policy_attachment" "ci-account-s3-attachments" {
  count      = length(local.ci-account-s3-policies)
  user       = aws_iam_user.ci-account.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.ci-account-s3-policies[count.index]}-read-write"
}

resource "aws_iam_user_policy_attachment" "service-account-s3-attachments" {
  count      = length(local.service-account-s3-policies)
  user       = aws_iam_user.service-account.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.service-account-s3-policies[count.index]}-read-write"
}

resource "aws_iam_user_policy_attachment" "dit-database-backups-account-s3-attachments" {
  user       = aws_iam_user.dit-database-backups-account.name
  policy_arn = aws_iam_policy.database-backups-read.arn
}


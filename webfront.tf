resource "aws_s3_bucket" "resume_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "unblock_bucket_public_access" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_views" {
  bucket     = aws_s3_bucket.resume_bucket.id
  policy     = data.aws_iam_policy_document.allow_public_views.json
  depends_on = [aws_s3_bucket_public_access_block.unblock_bucket_public_access]
}

data "aws_iam_policy_document" "allow_public_views" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.resume_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "resume_website" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}
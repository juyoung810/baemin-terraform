#S3는 생성
resource "aws_s3_bucket" "baemin-s3" {
  bucket = "baemin-static-s3"

  tags = {
    Name        = "baemin-static-s3"
    Environment = "Dev"
  }
}

#S3에 파일 업로드
resource "aws_s3_object" "test-object" {
  bucket = aws_s3_bucket.baemin-s3.id
  key    = "index.html"
  source = "uploads/index.html"
  content_type    = "text/html"
  etag = filemd5("uploads/index.html")
}

# # 버킷 정책
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.baemin-s3.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.test.iam_arn]
    }
  }
}
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.baemin-s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


resource "aws_cloudfront_origin_access_identity" "test" {
  comment = "This is a test distribution"
}

resource "aws_cloudfront_distribution" "baemin-s3-distribution" {
  origin {
    domain_name = aws_s3_bucket.baemin-s3.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.baemin-s3.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.test.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.baemin-s3.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
}

  price_class = "PriceClass_200"

# 특정 국가에서만 접근 가능하도록
  restrictions {
    geo_restriction {
      restriction_type = "none"
     #locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
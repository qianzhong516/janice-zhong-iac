// create the cert for CloudFront
resource "aws_acm_certificate" "us_cert" {
  provider                  = aws.us_east_1
  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}


resource "aws_acm_certificate_validation" "us_cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.us_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.us_cert : record.fqdn]
}

// create the cert for API Gateway
resource "aws_acm_certificate" "syd_cert" {
  domain_name       = local.api_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}


resource "aws_acm_certificate_validation" "syd_cert_validation" {
  certificate_arn         = aws_acm_certificate.syd_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.syd_cert : record.fqdn]
}

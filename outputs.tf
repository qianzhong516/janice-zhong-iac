output "cloudfront_domain" {
  value = module.cloudfront.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "site_bucket_name" {
  value = aws_s3_bucket.resume_bucket.bucket
}

output "site_website_endpoint" {
  value = aws_s3_bucket_website_configuration.resume_website.website_endpoint
}

output "site_domain" {
  value = aws_route53_record.cloudfront_a_record.fqdn
}

output "api_invoke_url" {
  value = aws_route53_record.api_a_record.fqdn
}

output "ddb_table_name" {
  value = aws_dynamodb_table.visits.name
}
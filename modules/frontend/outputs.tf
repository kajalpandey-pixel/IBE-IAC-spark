output "frontend_bucket" {
  value = aws_s3_bucket.frontend_bucket.bucket
}  

output "cloudfront_url" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}
output "s3_bucket_id" {
  value       = aws_s3_bucket.bucket_test.id
  description = "Nombre único del bucket"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.bucket_test.arn
  description = "Identificador ARN para políticas de IAM"
}

output "s3_bucket_region" {
  value       = aws_s3_bucket.bucket_test.region
  description = "Región donde reside el bucket"
}

output "s3_bucket_domain_name" {
  value       = aws_s3_bucket.bucket_test.bucket_domain_name
  description = "FQDN del bucket (útil si integran aplicaciones externas o APIs)"
}
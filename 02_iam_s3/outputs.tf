# =================================================
# Outputs de Infraestructura (S3)
# =================================================
output "storage_bucket_name" {
  value       = module.s3.s3_bucket_id
  description = "Nombre real del bucket generado (incluye el sufijo aleatorio)"
}

output "storage_bucket_arn" {
  value       = module.s3.s3_bucket_arn
  description = "ARN del bucket para configuraciones externas"
}

# =================================================
# Outputs de Acceso (IAM) - Información para el Equipo
# =================================================

# Datos para el Data Engineer
output "credentials_data_engineer" {
  value = {
    user          = var.user_name_de
    access_key_id = module.iam.de_access_key_id
    secret_key    = module.iam.de_secret_access_key
    password      = module.iam.de_password
  }
  sensitive = true
}

# Datos para los Data Scientists (Lista)
output "credentials_data_scientists" {
  value = {
    users           = [for i in range(2) : "${var.user_name_ds}-${i + 1}"]
    access_keys_ids = module.iam.ds_access_keys_ids
    secrets_keys    = module.iam.ds_secrets_access_keys
    passwords       = module.iam.ds_passwords
  }
  sensitive = true
}

output "aws_console_url" {
  value       = "https://signin.aws.amazon.com/console"
  description = "URL general para el acceso a la consola de AWS"
}
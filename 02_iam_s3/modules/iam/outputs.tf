# ======= Credenciales para el Data Engineer =======
output "de_access_key_id" {
  value       = aws_iam_access_key.de_keys.id
  description = "Access Key ID para el Data Engineer"
}

output "de_secret_access_key" {
  value       = aws_iam_access_key.de_keys.secret
  sensitive   = true
  description = "Secret Access Key para el Data Engineer"
}

output "de_password" {
  value       = aws_iam_user_login_profile.de_login.password
  description = "Contraseña temporal de consola para el Data Engineer"
}

# ======= Credenciales para los Data Scientists =======
output "ds_access_keys_ids" {
  value       = aws_iam_access_key.ds_keys[*].id
  description = "Lista de Access Key IDs para los Data Scientists"
}

output "ds_secrets_access_keys" {
  value       = aws_iam_access_key.ds_keys[*].secret
  sensitive   = true
  description = "Lista de Secret Access Keys para los Data Scientists"
}

output "ds_passwords" {
  value       = aws_iam_user_login_profile.ds_login[*].password
  description = "Contraseñas temporales de consola para los Data Scientists"
}
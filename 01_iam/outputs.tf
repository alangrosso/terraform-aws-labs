# Esto es vital para ver las llaves en la terminal
output "usuario_proyecto" {
  value       = aws_iam_user.usuario_proyecto.arn
  description = "ARN del usuario creado"
}

output "access_key_id" {
  value = aws_iam_access_key.llaves_usuario.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.llaves_usuario.secret
  sensitive = true # Evita que se imprima por accidente en los logs: oculta la clave en la pantalla normal
}
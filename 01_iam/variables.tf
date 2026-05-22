# Nombre del usuario de IAM que se va a CREAR
variable "iam_user_name" {
  description = "Nombre del usuario de IAM para el proyecto"
  type        = string
  default     = "usuario" # Nombre descriptivo para el nuevo recurso (opcional)
}

# Tags comunes para todos los recursos (Gobierno de Datos)
variable "common_tags" {
  description = "Mapa de etiquetas para aplicar a todos los recursos"
  type        = map(string)
  default = {
    Project   = "Test"
    Owner     = "Team"
    ManagedBy = "Terraform"
  }
}

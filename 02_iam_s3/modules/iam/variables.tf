# ======= Variables de Proyecto =======
variable "project_name" {
  description = "Nombre del proyecto para prefijar los recursos de IAM"
  type        = string
}

# ======= Variables de Integración (Outputs de S3) =======
variable "s3_bucket_arn" {
  description = "ARN del bucket de S3 (proveniente del módulo s3)"
  type        = string
}

# ======= Variables de Identidad (Usuarios) =======
variable "user_name_de" {
  description = "Nombre de usuario para el Data Engineer"
  type        = string
  default     = "cra-data-engineer"
}

variable "user_name_ds" {
  description = "Prefijo para los nombres de usuario de los Data Scientists"
  type        = string
  default     = "cra-data-scientist"
}

# ======= Variables de Notificación y Alertas =======
variable "admin_email" {
  description = "Correo electrónico del Lead DS para recibir alertas de presupuesto"
  type        = string
}
# =================================================
# Variables Globales de Proyecto
# =================================================
variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (poc, dev, prod)"
  type        = string
  default     = "poc"
}

variable "region" {
  description = "Región de AWS para el despliegue"
  type        = string
  default     = "us-east-1"
}

# =================================================
# Variables para el Módulo S3
# =================================================
variable "s3_bucket_prefix" {
  description = "Prefijo para el bucket"
  type        = string
}

variable "common_tags" {
  description = "Tags compartidos para todos los recursos"
  type        = map(string)
}

# =================================================
# Variables para el Módulo IAM (Usuarios)
# =================================================
variable "user_name_de" {
  description = "Nombre de usuario para el Data Engineer"
  type        = string
}

variable "user_name_ds" {
  description = "Prefijo para los nombres de los Data Scientists"
  type        = string
}

# =================================================
# Alerta: Gestión de Costos
# =================================================
variable "admin_email" {
  description = "Email del personal para alertas de presupuesto"
  type        = string
}
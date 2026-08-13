# ======= Prefijo para nombre de Bucket =======
variable "bucket_prefix" {
  description = "Prefijo para el nombre del bucket. AWS añadirá caracteres aleatorios al final."
  type        = string
  # default     = "bucket"  # se define en terraform.tfvars de root

  validation {
    condition     = length(var.bucket_prefix) <= 37
    error_message = "El prefijo no debe exceder los 37 caracteres."
  }
}

# ======= Entorno de Despliegue =======
variable "environment" {
  description = "Etiqueta del entorno (ej: poc, dev, test, prod)"
  type        = string
  default     = "poc"
}

# ======= Etiquetas (Tags) =======
variable "tags" {
  description = "Mapa de etiquetas para organizar y costear los recursos"
  type        = map(string)
  default = {
    Area        = "Credit Risk Analytics"
    Project     = "Storage"
    ManagedBy   = "Terraform"
  }
}

# ======= Configuración de Retención (Opcional pero recomendado) =======
variable "force_destroy" {
  description = "Si es true, el bucket se eliminará aunque tenga objetos dentro. Usar con precaución."
  type        = bool
  default     = false
}
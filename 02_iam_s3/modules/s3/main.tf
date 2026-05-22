# ======= Definición del Bucket =======
resource "aws_s3_bucket" "bucket_test" {
  # Cambiamos 'bucket' por 'bucket_prefix'
  bucket_prefix = var.bucket_prefix

  # force_destroy = true
  force_destroy = var.environment == "POC" ? true : false # Seguridad: Evita borrar datos en PROD

  tags = var.tags
}

# ======= Configuración de Seguridad: Bloquear todo acceso público =======
resource "aws_s3_bucket_public_access_block" "seguridad_s3" {
  bucket = aws_s3_bucket.bucket_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ======= Cifrado =======
resource "aws_s3_bucket_server_side_encryption_configuration" "cifrado_bucket_test" {
  bucket = aws_s3_bucket.bucket_test.id

  rule {
    apply_server_side_encryption_by_default {
      # cifrado por defecto y el más simple
      sse_algorithm = "AES256"
    }
  }
}

# ======= Habilitar Versionado =======
# Opcional pero recomendado para recuperar archivos borrados
resource "aws_s3_bucket_versioning" "versionado_bucket_test" {
  bucket = aws_s3_bucket.bucket_test.id
  versioning_configuration {
    status = "Enabled"
  }
}
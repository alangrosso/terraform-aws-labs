# =================================================
# Módulo S3: Infraestructura de Almacenamiento
# =================================================
module "s3" {
  source = "./modules/s3"
  # Usamos bucket_prefix para evitar colisiones de nombres globales
  bucket_prefix = var.s3_bucket_prefix

  environment = var.environment
  tags        = var.common_tags
}

# =================================================
# Módulo IAM: Identidades y Permisos
# =================================================
module "iam" {
  source        = "./modules/iam"
  s3_bucket_arn = module.s3.s3_bucket_arn

  project_name = var.project
  user_name_de = var.user_name_de
  user_name_ds = var.user_name_ds

  # Variable para alertas de presupuesto (Critical para el Lead DS)
  admin_email = var.admin_email
}
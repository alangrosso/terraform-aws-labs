# ======= Creación de Usuarios =======

# Usuario para el Data Engineer
resource "aws_iam_user" "data_engineer" {
  # name = "user-data-engineer"
  name = var.user_name_de

  tags = {
    Role = "DataEngineer"
    Area = "CRA"
  }
}

# Usuarios para los Data Scientists
resource "aws_iam_user" "data_scientist" {
  count = 2
  name = "${var.user_name_ds}-${count.index + 1}"
  tags = {
    Role = "DataScientist"
    Area = "CRA"
  }
}

# ======= Generación de Access Keys (Acceso Programático) =======

# Llaves para el Data Engineer
resource "aws_iam_access_key" "de_keys" {
  user = aws_iam_user.data_engineer.name
}

# Llaves para los Data Scientists
resource "aws_iam_access_key" "ds_keys" {
  count = 2
  user  = aws_iam_user.data_scientist[count.index].name  
}

# ======= Login a la Consola (Credenciales iniciales) =======
# Esto genera una contraseña temporal para el primer acceso

resource "aws_iam_user_login_profile" "de_login" {
  user = aws_iam_user.data_engineer.name
  # Se recomienda que el usuario cambie la clave en el primer login
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "ds_login" {
  count                   = 2
  user                    = aws_iam_user.data_scientist[count.index].name
  password_reset_required = true
}

# ======= Creación de Políticas =======

# Data Engineer Full Access
resource "aws_iam_policy" "s3_full_access" {
  name        = "${var.project_name}-s3-full-access"
  description = "Permiso total sobre el bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Permite ver lista global de buckets
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        # Permite listar el contenido específico del bucket
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = [var.s3_bucket_arn]
      },
      {
        # Permite descargar, subir y borrar archivos dentro del bucket
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = ["${var.s3_bucket_arn}/*"]
      }
    ]
  })
}

# Data Scientist Restringida
resource "aws_iam_policy" "s3_read_only" {
  name        = "${var.project_name}-s3-read-only"
  description = "Permiso de solo lectura para analistas"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Permite ver lista global de buckets
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        # Permite listar el contenido específico del bucket
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = [var.s3_bucket_arn]
      },
      {
        # Solo permite descargar, sin permiso de borrado o subida
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = ["${var.s3_bucket_arn}/*"]
      }
    ]
  })
}

# ======= Asignación de Permisos =======
# Vinculamos a los usuarios con las políticas que ya creamos

resource "aws_iam_user_policy_attachment" "de_attach" {
  user       = aws_iam_user.data_engineer.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_user_policy_attachment" "ds_attach" {
  count      = 2
  user       = aws_iam_user.data_scientist[count.index].name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

# ======= Configurar alerta de costos =======
resource "aws_budgets_budget" "limite_costos" {
  name         = "presupuesto-mensual"
  budget_type  = "COST"
  limit_amount = "10" # dólares
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["tu-email@ejemplo.com"] # actualizar
  }
}
# Crear el Usuario IAM
resource "aws_iam_user" "usuario_proyecto" {
  name = var.iam_user_name
  tags = merge(var.common_tags, {
    Cargo = "IAM-Proyecto"
  })
}

# Crear las llaves de acceso para este nuevo usuario
resource "aws_iam_access_key" "llaves_usuario" {
  user = aws_iam_user.usuario_proyecto.name
}

# Configurar alerta de costos
resource "aws_budgets_budget" "limite_aprendizaje" {
  name         = "presupuesto-mensual-${var.iam_user_name}"
  budget_type  = "COST"
  limit_amount = "10" # dólares
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["tu-email@ejemplo.com"]
  }
}


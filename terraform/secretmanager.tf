resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "*?"
}

# Creating a AWS secret for database master account (Masteraccoundb)

resource "aws_secretsmanager_secret" "keycloak-db-secret" {
  name = "keycloak-db-secret"
}

# Creating a AWS secret versions for database master account (Masteraccoundb)

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.keycloak-db-secret.id
  secret_string = <<EOF
   {
    "username": "keycloak",
    "password": "${random_password.password.result}"
   }
EOF
}

# Importing the AWS secrets created previously using arn.

data "aws_secretsmanager_secret" "keycloak-db-secret" {
  arn = aws_secretsmanager_secret.keycloak-db-secret.arn
}

# Importing the AWS secret version created previously using arn.

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.keycloak-db-secret.arn
}

# After importing the secrets storing into Locals
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}







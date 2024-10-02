resource "aws_db_instance" "postgresql" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  db_name              = "keycloak"
  username             = local.db_creds.username
  password             = local.db_creds.password
  parameter_group_name = "default.postgres15"
  identifier           = "keycloak-rds"

  db_subnet_group_name   = aws_db_subnet_group.default.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "KeycloakDB"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "rds_subnet_group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow RDS PostgreSQL access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.vpc_private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

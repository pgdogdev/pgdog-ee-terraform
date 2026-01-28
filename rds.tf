data "aws_vpc" "selected" {
  count = var.create_rds ? 1 : 0
  id    = var.vpc_id
}

resource "aws_security_group" "rds" {
  count = var.create_rds ? 1 : 0

  name        = "${var.db_identifier}-rds-sg"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.db_identifier}-rds-sg"
  })
}

resource "random_password" "db_password" {
  count = var.create_rds ? 1 : 0

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "postgres" {
  count = var.create_rds ? 1 : 0

  identifier = var.db_identifier

  engine         = "postgres"
  engine_version = var.postgres_version

  instance_class        = "db.m5.large"
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = coalesce(var.db_password, random_password.db_password[0].result)

  multi_az               = false
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = var.tags
}

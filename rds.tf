# Get the RDS password from SSM
data "aws_ssm_parameter" "rds_password" {
  name = "/Tarurak/WWW/DB/Password"
}

resource "aws_db_instance" "WP-RDS" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "aurora-mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  name                 = "taurak-wp"
  username             = "dbadmin"
  password             = "${data.aws_ssm_parameter.rds_password.value}"
  parameter_group_name = "default.aurora5.6"
}

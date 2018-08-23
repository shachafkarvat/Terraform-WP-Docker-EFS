# Get the RDS password from SSM
data "aws_ssm_parameter" "rds_password" {
  name = "/Tarurak/WWW/DB/Password"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_db_subnet_group" "WP_rds_sng" {
  name       = "wp-rds"
  subnet_ids = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-c.id}"]
}

resource "aws_db_instance" "WP-RDS" {
  allocated_storage      = 10
  storage_type           = "gp2"
  name                   = "taurakwp"
  username               = "dbadmin"
  password               = "${data.aws_ssm_parameter.rds_password.value}"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = "${aws_db_subnet_group.WP_rds_sng.name}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]

  # apply_immediately      = "${var.apply_immediately}"
  skip_final_snapshot = true
}

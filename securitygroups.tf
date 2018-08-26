resource "aws_security_group" "elb-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "elb-sg"

  ingress = [
    {
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = "443"
      to_port     = "443"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "nginx-instances-sg"

  ingress = [
    {
      from_port       = "80"
      to_port         = "80"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb-sg.id}"]
    },
    {
      from_port       = "8080"
      to_port         = "8080"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb-sg.id}"]
    },
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb-sg.id}"]
    },
    {
      from_port       = "22"
      to_port         = "22"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.bastion-sg.id}"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "bastion-sg"

  ingress = [
    {
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "WP-rds-mysql-sg"
  description = "RDS MySQL Security Group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port       = "3306"
      to_port         = "3306"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.nginx-sg.id}"]
    },
  ]
}

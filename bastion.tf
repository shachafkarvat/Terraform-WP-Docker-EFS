# Bastion

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.small"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = "${aws_subnet.subnet-a.id}"
  associate_public_ip_address = true
  key_name                    = "${var.keyname}"

  tags {
    Name = "Bastion"
  }

  user_data = <<EOF
#!/bin/sh
apt update
hostname "BASTION"
EOF
}

// resource "aws_security_group" "bastion-sg" {
//   vpc_id = "${aws_vpc.vpc.id}"
//   name   = "bastion-sg"

//   ingress = [
//     {
//       from_port   = "22"
//       to_port     = "22"
//       protocol    = "tcp"
//       cidr_blocks = ["0.0.0.0/0"]
//     },
//   ]

//   egress {
//     from_port   = 0
//     to_port     = 0
//     protocol    = "-1"
//     cidr_blocks = ["0.0.0.0/0"]
//   }
// }

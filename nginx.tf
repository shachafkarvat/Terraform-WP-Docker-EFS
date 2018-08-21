## Creating Launch Configuration
resource "aws_launch_configuration" "nginx-lc" {
  image_id = "${data.aws_ami.ubuntu.id}"

  # image_id                    = "${var.ami}"
  instance_type        = "${var.ec2-size}"
  security_groups      = ["${aws_security_group.nginx-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.nginx.id}"
  key_name             = "${var.keyname}"

  #   name                        = "${var.basename}-lc"
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/sh
hostname Nginx
apt-get update
apt install -y docker.io awscli
while [ ! -S /var/run/docker.sock ] ; do sleep 2; done
aws s3 cp s3://taurak.co.uk-artefacts/debs/amazon-efs-utils-1.3-1.deb /root
apt-get -y install /root/amazon-efs-utils*deb
chgrp ubuntu /var/run/docker.sock
mkdir /var/WWW
chown ubuntu:ubuntu /var/WWW
echo "=== Mounting EFS ==="

echo "Running nginx"
/usr/bin/docker run -d -p 80:80 --name=nginx nginx
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx-asg" {
  launch_configuration = "${aws_launch_configuration.nginx-lc.id}"

  # availability_zones   = ["${data.aws_availability_zones.all.names}"]
  vpc_zone_identifier = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-c.id}"]
  min_size            = 1
  max_size            = 3
  load_balancers      = ["${aws_elb.nginx-elb.name}"]
  health_check_type   = "ELB"

  tag {
    key                 = "Name"
    value               = "nginx-asg"
    propagate_at_launch = true
  }
}

### Creating ELB
resource "aws_elb" "nginx-elb" {
  name            = "${var.basename}-lb"
  security_groups = ["${aws_security_group.elb-sg.id}"]
  subnets         = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-c.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  # listener {
  #   lb_port           = 443
  #   lb_protocol       = "http"
  #   instance_port     = "443"
  #   instance_protocol = "https"
  # }
}

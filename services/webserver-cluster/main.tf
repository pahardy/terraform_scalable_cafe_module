#Creating SG to allow the HTTP traffic to the EC2 instances
resource "aws_security_group" "sg_cafe" {
  name = "${var.cluster_name}-cafe-allow-http"
  description = "Allow HTTP traffic to the instances hosting the cafe app"
  vpc_id = data.aws_vpc.default-vpc.id
}

#Creating SG to allow HTTP traffic to the LB
resource "aws_security_group" "sg_cafe-lb" {
  name = "${var.cluster_name}-cafe-allow-http-lb"
  description = "Allow HTTP traffic to the LB fronting the cafe app"
  vpc_id = data.aws_vpc.default-vpc.id
}

resource "aws_security_group_rule" "allow_http_inbound-lb" {
  from_port         = local.http_port
  protocol          = local.tcp_protocol
  security_group_id = aws_security_group.sg_cafe-lb.id
  to_port           = local.http_port
  type              = "ingress"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_inbound-instance" {
  from_port         = local.http_port
  protocol          = local.tcp_protocol
  security_group_id = aws_security_group.sg_cafe.id
  to_port           = local.http_port
  type              = "ingress"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound-lb" {
  from_port         = local.any_port
  protocol          = local.any_protocol
  security_group_id = aws_security_group.sg_cafe-lb.id
  to_port           = local.any_port
  type              = "egress"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound-instance" {
  from_port         = local.any_port
  protocol          = local.any_protocol
  security_group_id = aws_security_group.sg_cafe.id
  to_port           = local.any_port
  type              = "egress"
  cidr_blocks = local.all_ips
}

#Creating the AWS launch configuration
resource "aws_launch_configuration" "aws_launch_config_cafe" {
  name          = "${var.cluster_name}-cafe_launch_config"
  image_id      = var.cafe-ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.sg_cafe.id]
  user_data = file("../../../app1-install.sh")

  lifecycle {
    create_before_destroy = true
  }
}

#Creating the AutoScaling group
resource "aws_autoscaling_group" "aws_asg_cafe" {
  name = "${var.cluster_name}-asg_cafe"
  max_size = var.asg-max
  min_size = var.asg-min
  desired_capacity = var.asg-desired
  launch_configuration = aws_launch_configuration.aws_launch_config_cafe.name
  vpc_zone_identifier = data.aws_subnets.asg-subnets.ids
  target_group_arns = [aws_lb_target_group.cafe-lb-target-group.arn]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-scalable-cafe-app"
    propagate_at_launch = true
  }
}

#Creating the load balancer
resource "aws_lb" "cafe-app-lb" {
  name = "${var.cluster_name}-cafe-app-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.asg-subnets.ids
  security_groups = [aws_security_group.sg_cafe-lb.id]
}

#Creating listener for the load balancer
resource "aws_lb_listener" "cafe-lb-listener" {
  load_balancer_arn = aws_lb.cafe-app-lb.arn
  port = local.http_port
  protocol = "HTTP"

  default_action {
    type             = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not found"
      status_code = 404
    }
  }
}

#Create target group for the LB
resource "aws_lb_target_group" "cafe-lb-target-group" {
  name = "${var.cluster_name}-cafe-lb-tg"
  port = var.http-port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default-vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "cafe-lb-listener-rule" {
  listener_arn = aws_lb_listener.cafe-lb-listener.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cafe-lb-target-group.arn
  }
}


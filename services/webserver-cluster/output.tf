#Report the DNS name of the LB for client access
output "lb_dns_name" {
  value = aws_lb.cafe-app-lb.dns_name
}

output "asg_name" {
  description = "Name of ASG"
  value = aws_autoscaling_group.aws_asg_cafe.name
}

output "aws-sg-id-lb" {
  description = "SG ID for LB"
  value = aws_security_group.sg_cafe-lb.id
}

output "aws-sg-id-instance" {
  description = "SG ID for instance"
  value = aws_security_group.sg_cafe.id
}
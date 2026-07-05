output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

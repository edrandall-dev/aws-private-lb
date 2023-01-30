output "loadbalacer_address" {
  description = "The URL of the Application Load Balancer"
  value       = "http://${aws_lb.test_env_alb.dns_name}"
}

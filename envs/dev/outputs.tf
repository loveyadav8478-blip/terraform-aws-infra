output "alb_dns_name" {
  description = "Public URL of the load balancer - hit this to test the app"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

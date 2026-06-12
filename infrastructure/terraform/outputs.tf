# ── Networking Outputs ────────────────────────────────

output "vpc_id" {
    description = "ID of the VPC"
    value       = aws_vpc.main.id
}

output "public_subnet_ids" {
    description = "IDs of public subnets"
    value        = aws_subnet.public[*].id
}

output "private_subnet_ids" {
    description = "IDs of private subnets"
    value        = aws_subnet.private[*].id
}

# ── ALB Outputs ───────────────────────────────────────
output "alb_dns_name" {
    description = "DNS name of the Application Load Balancer"
    value       = aws_lb.main.dns_name 
}

output "alb_zone_id" {
    description = "Zone ID of the ALB for Route53 alias records"
    value       = aws_lb.main.zone_id
}

# ── ECR Outputs ───────────────────────────────────────

output "frontend_repository_url" {
    description  = "ECR repository URL for frontend image"
    value         = aws_ecr_repository.frontend.repository_url

}

output "backend_repository_url" {
    description = "ECR repository URL for backend image"
    value        = aws_ecr_repository.backend.repository_url
}

# ── ECS Outputs ───────────────────────────────────────

output "ecs_cluster_name" {
    description   = "Name of the ECS cluster"
    value          = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
    description   = "ARN of the ECS cluster"
    value         = aws_ecs_cluster.main.id
}

output "frontend_service_name" {
    description       = "Name of the frontend ECS service"
    value             = aws_ecs_service.frontend.name
}

output "backend_service_name" {
    description       = "Name of the backend ECS service"
    value             = aws_ecs_service.backend.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# ── Monitoring Outputs ────────────────────────────────

output "monitoring_public_ip" {
  description = "Public IP of the monitoring server"
  value       = aws_eip.monitoring.public_ip
}

output "prometheus_url" {
  description = "URL to access Prometheus UI"
  value       = "http://${aws_eip.monitoring.public_ip}:${var.prometheus_port}"
}

output "grafana_url" {
  description = "URL to access Grafana UI"
  value       = "http://${aws_eip.monitoring.public_ip}:${var.grafana_port}"
}

output "alertmanager_url" {
  description = "URL to access AlertManager UI"
  value       = "http://${aws_eip.monitoring.public_ip}:${var.alertmanager_port}"
}

# ── AWS Account Outputs ───────────────────────────────

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}
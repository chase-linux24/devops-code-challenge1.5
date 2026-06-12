# ── Project Identity ──────────────────────────────────────────────────────────
variable "project_name" {
    description = "Name prefix for all resources."
    type        = string
    default     = "devops-challenge"
}

variable "environment" {
    description = "Deployment enviornmet."
    type        = string
    default     = "production"
}

# ── AWS Configuration ─────────────────────────────────

variable "aws_region" {
    description  = "AWS region  where all resources will be deployed."
    type         = string
    default      = "us-east-2"
}

# ── Network Configuration ─────────────────────────────
variable "vpc_cidr" {
    description = "CIDR block for the VPC."
    type        = string 
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "CIDR block for the public subnets."
    type        = list (string)
    default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "availability_zones" {
  description = "Availability zones to deploy into."
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

# ── ECS Configuration ─────────────────────────────────

variable "frontend_cpu" {
  description = "CPU units for the frontend ECS task."
  type        = number
  default     = 256
} 

variable "frontend_memory" {
    description = "Memory in  MB for the frontend ECS task."
    type        = number
    default     = 512
}

variable "backend_cpu" {
    description = "CPU units for the backend ECS tasks."
    type        = number
    default     = 256
}

variable "backend_memory" {
    description = "Memory in MB for the backend ECS task."
    type        = number
    default     = 512
}

variable "frontend_port" {
    description = "Port the backend container listens on."
    type        = number 
    default     = 8080
}

variable "backend_port" {
    description = "Port the frontend container listens on."
    type        = number
    default     = 3000
}

variable "desired_tasks" {
    description = "Desired number of running task per ECS service."
    type        = number 
    default     = 1
}

# ── ECR Configuration ─────────────────────────────────

variable "ecr_lifecycle_count" {
  description = "Max number of images to retain in ECR."
  type        = number
  default     = 10
}

# ── Monitoring Configuration ──────────────────────────

variable "monitoring_instance_type" {
    description = "EC2 instance type for Prometheus and Grafana."
    type        = string
    default     = "t3.small"
}

variable "prometheus_port" {
    description = "Port Prometheus listens on."
    type        = number
    default     = 9090
}

variable "grafana_port" {
    description = "Port Grafana listens on."
    type        = number
    default     = 3001
}

variable "alertmanager_port" {
    description = "How frequently Prometheus scrapes metrics."
    type        = string
    default     = "15s"
}

variable "prometheus_scrape_interval" {
  description = "How frequently Prometheus scrapes metrics."
  type        = string
  default     = "15s"
}

# ── Jenkins Configuration ─────────────────────────────

variable "jenkins_instance_type" {
    description = "EC2 instance type for Jenkins."
    type        = string
    default     = "t3.small"
}

variable "key_pair_name" {
    description = "EC2 key pair name for SSH access."
    type        = string
    default     = "1pu-keypair"
}
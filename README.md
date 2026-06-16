# DevOps Tech Challenge 1.5
## GitOps | Prometheus | Grafana | ECS Fargate | GitHub Actions

An evolution of Tech Challenge 1 — Node.js full-stack app on AWS ECS Fargate with production-grade GitOps, observability, and security.

## Tech Stack

| Component | Technology | Purpose |
|---|---|---|
| Application | Node.js Express + React | Backend API + Frontend UI |
| Containers | Docker + Amazon ECR | Immutable git SHA image tags |
| Orchestration | AWS ECS Fargate | Serverless containers in private subnets |
| Load Balancer | AWS ALB | Path-based routing and health checks |
| CI/CD | GitHub Actions | GitOps pipeline with OIDC auth |
| Infrastructure | Terraform | Remote state in S3, 46 resources as code |
| Metrics | prom-client | RED metrics at /metrics endpoint |
| Monitoring | Prometheus | Scrapes backend every 15 seconds |
| Dashboards | Grafana | Real-time RED metrics visualization |
| Alerting | AlertManager | Critical alert routing |

## Pipeline - 4 Jobs, 7 Minutes 35 Seconds

Every push to main triggers the full pipeline automatically.

1. **Test Application** (33s) - npm install and test
2. **Provision Infrastructure** (4m) - terraform apply, 46 AWS resources
3. **Build and Push** (1m 20s) - Docker build with git SHA tag, push to ECR
4. **Deploy to ECS** (1m 11s) - Update task definitions, rolling deployment

## What Makes This Production-Grade

**GitOps** - Every change flows through Git. Hourly drift detection opens a GitHub issue if manual changes are detected in AWS.

**OIDC Authentication** - No stored AWS credentials. GitHub Actions assumes an IAM role via OpenID Connect. Credentials expire when each job finishes.

**Immutable Image Tags** - Every image tagged with full git SHA. Complete traceability from running container back to exact commit.

**Private Subnets** - ECS tasks unreachable from internet. Only the ALB can reach them. NAT Gateway for outbound ECR pulls only.

**RED Metrics** - Rate, Errors, Duration instrumented with prom-client. Visualized in Grafana with real-time dashboards.

**Remote State** - Terraform state in S3 with DynamoDB locking. Safe for team collaboration.

## Monitoring Stack

Prometheus and Grafana on dedicated EC2 (t3.small), separate from application infrastructure.

**Metrics collected:**
- http_requests_total - Counter labeled by method, route, status_code
- http_request_duration_seconds - Histogram with buckets 1ms to 5s
- devops_challenge_process_* - 15+ default Node.js metrics

**PromQL queries:**
- Rate: rate(http_requests_total[5m])
- Errors: rate(http_requests_total{status_code=~"5.."}[5m])
- Duration p95: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

**Alerts:**
- BackendDown - critical after 1 minute unreachable
- HighErrorRate - warning when 5xx exceeds 5 percent
- HighResponseTime - warning when p95 latency exceeds 500ms

## AWS Resources (46 total)

VPC, 4 subnets across 2 AZs, Internet Gateway, NAT Gateway, 5 security groups, 2 ECR repos, ECS cluster, 2 IAM roles, 2 CloudWatch log groups, 2 task definitions, 2 ECS services, ALB, 2 target groups, listener, listener rule, 2 autoscaling targets, 4 autoscaling policies, monitoring EC2.

## Author

Chase D. Ealy - RHCSA Certified - Junior Linux Infrastructure Engineer
Procore Technologies Apprenticeship | Yellowtail Tech | 1% University AWS Cloud Engineering
GitHub: github.com/chase-linux24

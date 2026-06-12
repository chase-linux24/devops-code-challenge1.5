# ── ECR Repositories ──────────────────────────────────

resource "aws_ecr_repository" "frontend" {
    name                 = "${var.project_name}-frontend"
    image_tag_mutability = "IMMUTABLE"  
    force_delete         = true

    image_scanning_configuration {
        scan_on_push     = true 
    }

    tags = {
    Name = "${var.project_name}-frontend-repo"
  }
}

resource "aws_ecr_repository" "backend" {
    name                  = "${var.project_name}-backend"
    image_tag_mutability  = "IMMUTABLE"
    force_delete          = true

    image_scanning_configuration {
        scan_on_push      = true 
    }

    tags = {
    Name = "${var.project_name}-backend-repo"
  }
}

# ── ECR Lifecycle Policies ────────────────────────────

resource "aws_ecr_lifecycle_policy" "frontend" {
    repository = aws_ecr_repository.frontend.name

    policy = jsonencode({
        rules =[
           {
             rulePriority = 1
        description  = "Keep last N images, expire older ones"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_lifecycle_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last N images, expire older ones"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_lifecycle_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
# ── ECS Autoscaling ───────────────────────────────────
resource "aws_appautoscaling_target" "frontend" {
    max_capacity       = 4
    min_capacity       = 1
    resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
    scalable_demension = "ecs:service:DesiredCount"
    service_namespace  = "ecs"
}

# ── CPU Scaling Policies ──────────────────────────────
resource "aws_appautoscaling_policy" "frontend_cpu" {
    name               = "${var.project_name}-frontend-cpu-scaling"
    policy_type        = "TargetTrackingScaling"
    resource_id        = aws_autoscaling_target.frontend.resource_id
    scalable_demension = aws_appautoscaling_target.frontend.scalable_demension
    service_namespace  = aws_appautoscaling_target.frontend.service.service_namespace

    target_tracking_scaling_policy_configuration {
        predefined_metric_specification {
            predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value       = 70
        scale_in_cooldown  = 300
        scale_out_cooldown = 60
    }
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${var.project_name}-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ── Memory Scaling Policies ───────────────────────────

resource "aws_appautoscaling_policy" "frontend_memory" {
  name               = "${var.project_name}-frontend-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "backend_memory" {
  name               = "${var.project_name}-backend-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
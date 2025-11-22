
# 1. IAM ROLES 


# ECS Task Execution Role (for pulling ECR images and writing logs)

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-fargate-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the required AWS-managed policy for task execution

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for the container to access other AWS services if needed)

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-fargate-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}


# 2. ECS CLUSTER AND TASK DEFINITION


resource "aws_ecs_cluster" "cluster" {
  name = "docker-cluster"
}

resource "aws_ecs_task_definition" "td" {
  family                   = "app-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  # Reference the dynamically created IAM roles

  task_role_arn      = aws_iam_role.ecs_task_role.arn      # Task Role
  execution_role_arn = aws_iam_role.ecs_execution_role.arn # Execution Role 

  # Minimum recommended Fargate compute for small tasks

  cpu    = "256"
  memory = "512"

  lifecycle {
    ignore_changes = [container_definitions]
  }

  container_definitions = jsonencode([
    {
      name = "app"

      # Dynamic ECR URI using interpolation
      image     = "${aws_ecr_repository.repo.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80 #App SG ingress rule uses this port 
          hostPort      = 80
        }
      ]

      # Log configuration for CloudWatch

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app-task-definition"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


# 3. ECS SERVICE (Deploying the Tasks)

resource "aws_ecs_service" "service" {
  name                               = "app-service"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.td.arn
  launch_type                        = "FARGATE"
  desired_count                      = 2
  enable_execute_command             = true
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds = 60

  network_configuration {

    assign_public_ip = false
    subnets          = [aws_subnet.sn2.id, aws_subnet.sn3.id]
    security_groups  = [aws_security_group.app_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 80
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_execution_role_policy, aws_lb_listener.app_listener]
}

# 4. CloudWatch Log Group (for Fargate Logs)

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/app-task-definition"
  retention_in_days = 7
}
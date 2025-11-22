# 1. Application Load Balancer (ALB)

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]


  subnets = [aws_subnet.sn1.id, aws_subnet.sn4.id]

  # SECURITY/OPERATIONAL FIX: Prevents accidental deletion of the load balancer.
  enable_deletion_protection = false 

  tags = {
    Name = "app-alb"
  }
}

# 2. Target Group (No changes needed)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.docker_vpc.id

  # CRITICAL for Fargate: Target type must be 'ip', not 'instance'
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-target-group"
  }
}


# 3. ALB Listener (HTTP) (No changes needed)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
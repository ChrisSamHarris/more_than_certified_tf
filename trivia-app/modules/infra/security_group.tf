# Security Groups for ALB 
resource "aws_security_group" "infra-alb-sg" {
  name        = "mtc-ecs-alb-sg"
  description = "SG for MTC ECS Project"
  vpc_id      = aws_vpc.infra-vpc.id

  tags = {
    Name    = "mtc-ecs-alb-sg",
    Project = "mtc"
  }
}

resource "aws_vpc_security_group_ingress_rule" "infra-alb-sg-ingress" {
  for_each          = var.allowed_ips
  security_group_id = aws_security_group.infra-alb-sg.id

  cidr_ipv4   = each.value
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "infra-alb-sg-egress" {
  security_group_id            = aws_security_group.infra-alb-sg.id
  referenced_security_group_id = aws_security_group.infra-app-sg.id
  ip_protocol                  = "-1"

  tags = {
    Name    = "mtc-ecs-alb-sg-egress",
    Project = "mtc"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "infra-app-sg" {
  name        = "mtc-ecs-app-sg"
  description = "SG for MTC ECS Project, allowing traffic from the load balancer to ECS Tasks"
  vpc_id      = aws_vpc.infra-vpc.id

  tags = {
    Name    = "mtc-ecs-app-sg",
    Project = "mtc"
  }
}



resource "aws_vpc_security_group_ingress_rule" "infra-app-sg-ingress" {
  security_group_id            = aws_security_group.infra-app-sg.id
  referenced_security_group_id = aws_security_group.infra-alb-sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8501
  to_port                      = 8501
}

resource "aws_vpc_security_group_egress_rule" "infra-app-sg-egress" {
  security_group_id = aws_security_group.infra-app-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name    = "mtc-ecs-app-sg-egress",
    Project = "mtc"
  }
}
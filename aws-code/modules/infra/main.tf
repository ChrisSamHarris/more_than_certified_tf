resource "aws_vpc" "infra-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name    = "mtc-ecs-vpc",
    Project = "mtc"
  }
}

resource "aws_internet_gateway" "infra-gw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name    = "mtc-ecs-igw",
    Project = "mtc"
  }
}

# Removed - Redundant code 
# resource "aws_internet_gateway_attachment" "infra-gw-attachment" {
#   internet_gateway_id = aws_internet_gateway.infra-gw.id
#   vpc_id              = aws_vpc.infra-vpc.id
# }

resource "aws_route_table" "infra-rt" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name    = "mtc-ecs-rt",
    Project = "mtc"
  }
}

resource "aws_route" "infra-r" {
  route_table_id         = aws_route_table.infra-rt.id
  destination_cidr_block = "0.0.0.0/0" # Default route for all traffic - External 
  gateway_id             = aws_internet_gateway.infra-gw.id
}

resource "aws_subnet" "infra-subnet" {
  for_each          = { for i in range(var.num_subnets) : "public-${i}" => i }
  vpc_id            = aws_vpc.infra-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.infra-vpc.cidr_block, 8, each.value)
  # modulo operator to cycle through availability zones for each subnet
  # ensures subnets are distributed across different AZs for high availability
  availability_zone = local.a_zones[each.value % length(local.a_zones)]

  tags = {
    Name    = "mtc-ecs-subnet-${each.key}",
    Project = "mtc"
  }
}

resource "aws_route_table_association" "infra-rt-association" {
  for_each       = aws_subnet.infra-subnet
  subnet_id      = aws_subnet.infra-subnet[each.key].id
  route_table_id = aws_route_table.infra-rt.id
}

resource "aws_lb" "infra-lb" {
  name               = "mtc-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.infra-alb-sg.id]
  subnets            = [for subnet in aws_subnet.infra-subnet : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name    = "mtc-ecs-lb",
    Project = "mtc"
  }
}

resource "aws_lb_listener" "infra-lb-listener" {
  load_balancer_arn = aws_lb.infra-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "ECS Tasks are currently unavailable. Please try again later."
      status_code  = "503"
    }

  }
}

############ ECS CLUSTER RESOURCES ############
resource "aws_ecs_cluster" "infra-ecs-cluster" {
  name = "mtc-ecs-cluster"
}

resource "aws_iam_role" "logic-iam-role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name    = "mtc-ecs-iam-role",
    Project = "mtc"
  }
}

resource "aws_iam_role_policy_attachment" "logic-iam-policy-attachment" {
  role       = aws_iam_role.logic-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
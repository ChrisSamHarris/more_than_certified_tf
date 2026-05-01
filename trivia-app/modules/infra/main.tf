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
  for_each   = { for i in range(var.num_subnets) : "public-${i}" => i }
  vpc_id     = aws_vpc.infra-vpc.id
  cidr_block = cidrsubnet(aws_vpc.infra-vpc.cidr_block, 8, each.value)
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
  subnets            = [for az, id in { for s in aws_subnet.infra-subnet : s.availability_zone => s.id... } : id[0]]

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

######### EC2 Import Resources #########

# import {
#   # terraform plan -generate-config-out=generated.tf -> This will generate a plan but it conflicts with ipv6 address & primary NI
#  Identify any bugs in the generated configuration and fix them before applying the import.
#   to = aws_instance.infra-imported-ec2-instance
#   id = "<INSTANCE_ID>"
# }
# Imported 
# 
# Exercise for next time -> Required to import the Security Group 
# 
# resource "aws_instance" "infra-imported-ec2-instance" {
#   ami                                  = "<AMI_ID>"
#   availability_zone                    = "eu-west-2b"
#   disable_api_stop                     = false
#   disable_api_termination              = false
#   ebs_optimized                        = false
#   force_destroy                        = false
#   get_password_data                    = false
#   hibernation                          = false
#   instance_initiated_shutdown_behavior = "stop"
#   instance_type                        = "t2.micro"
#   key_name                             = "test-instance"
#   monitoring                           = false
#   placement_partition_number           = 0
#   private_ip                           = "<PRIVATE_IP>"
#   region                               = "eu-west-2"
#   secondary_private_ips                = []
#   security_groups                      = ["launch-wizard-1"]
#   source_dest_check                    = true
#   subnet_id                            = "<SUBNET_ID>"
#   tags = {
#     Name = "test-import-server"
#   }
#   tags_all = {
#     Name = "test-import-server"
#   }
#   tenancy                     = "default"
#   user_data                   = null
#   user_data_replace_on_change = null
#   volume_tags                 = null
#   vpc_security_group_ids      = ["<SECURITY_GROUP_ID>"]
#   capacity_reservation_specification {
#     capacity_reservation_preference = "open"
#   }
#   cpu_options {
#     core_count       = 1
#     threads_per_core = 1
#   }
#   credit_specification {
#     cpu_credits = "standard"
#   }
#   enclave_options {
#     enabled = false
#   }
#   maintenance_options {
#     auto_recovery = "default"
#   }
#   metadata_options {
#     http_endpoint               = "enabled"
#     http_protocol_ipv6          = "disabled"
#     http_put_response_hop_limit = 2
#     http_tokens                 = "required"
#     instance_metadata_tags      = "disabled"
#   }
#   private_dns_name_options {
#     enable_resource_name_dns_a_record    = true
#     enable_resource_name_dns_aaaa_record = false
#     hostname_type                        = "ip-name"
#   }
#   root_block_device {
#     delete_on_termination = true
#     encrypted             = false
#     iops                  = 3000
#     tags                  = {}
#     tags_all              = {}
#     throughput            = 125
#     volume_size           = 8
#     volume_type           = "gp3"
#   }
# }
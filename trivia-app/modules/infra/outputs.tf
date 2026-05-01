output "aws_subnets" {
  value = aws_subnet.infra-subnet
}

output "execution-role-arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "aws-ecs-cluster" {
  value = aws_ecs_cluster.infra-ecs-cluster.arn
}

output "mtc-subnets" {
  value = [for i in aws_subnet.infra-subnet : i.id]
}

output "all-infra-subnets" {
  value = aws_subnet.infra-subnet
}

output "ecs-app-sg" {
  value = aws_security_group.infra-app-sg.id
}

output "vpc-id" {
  value = aws_vpc.infra-vpc.id
}

output "alb_listener_arn" {
  value = aws_lb_listener.infra-lb-listener.arn
}
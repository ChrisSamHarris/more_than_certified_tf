resource "aws_vpc" "infra-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "mtc-ecs-vpc",
    Project = "mtc"
  }
}

resource "aws_internet_gateway" "infra-gw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name = "mtc-ecs-igw",
    Project = "mtc"
  }
}

resource "aws_internet_gateway_attachment" "infra-gw-attachment" {
  internet_gateway_id = aws_internet_gateway.infra-gw.id
  vpc_id              = aws_vpc.infra-vpc.id
}

resource "aws_route_table" "infra-rt" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name = "mtc-ecs-rt",
    Project = "mtc"
  }
}

resource "aws_route" "infra-r" {
  route_table_id            = aws_route_table.infra-rt.id
  destination_cidr_block    = "0.0.0.0/0" # Default route for all traffic - External 
  gateway_id                = aws_internet_gateway.infra-gw.id
}

resource "aws_subnet" "infra-subnet" {
  for_each = { for i in range(var.num_subnets) : "public-${i}" => i }
  vpc_id     = aws_vpc.infra-vpc.id
  cidr_block = cidrsubnet(aws_vpc.infra-vpc.cidr_block, 8, each.value)

  tags = {
    Name = "mtc-ecs-subnet-${each.key}",
    Project = "mtc"
  }
}
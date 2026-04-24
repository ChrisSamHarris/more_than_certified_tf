resource "aws_vpc" "infra-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name    = "trivia-app-vpc",
    Project = "trivia-app"
  }
}

resource "aws_internet_gateway" "infra-gw" {
  vpc_id = aws_vpc.infra-vpc.id

  tags = {
    Name    = "trivia-app-igw",
    Project = "trivia-app"
  }
}
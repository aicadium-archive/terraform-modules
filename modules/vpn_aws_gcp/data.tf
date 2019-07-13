data "aws_subnet_ids" "subnets" {
  vpc_id = var.aws_vpc_id
}

data "aws_route_tables" "tables" {
  vpc_id = var.aws_vpc_id

  filter {
    name   = "association.subnet-id"
    values = data.aws_subnet_ids.subnets.ids
  }
}

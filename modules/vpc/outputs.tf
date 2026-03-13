output "vpc_id"                { value = aws_vpc.main.id }
output "public_subnet_ids"     { value = aws_subnet.public[*].id }
output "private_subnet_ids"    { value = aws_subnet.private[*].id }
output "rds_subnet_group_name" { value = aws_db_subnet_group.main.name }
output "nat_gateway_id"        { value = aws_nat_gateway.main.id }
output "nat_eip"               { value = aws_eip.nat.public_ip }

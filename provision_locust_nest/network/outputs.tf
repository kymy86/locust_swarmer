output "locust_vpc_id" {
    value = "${aws_vpc.locust_vpc.id}"
}

output "locust_subnet_id" {
    value = "${aws_subnet.public_subnet.id}"
}

output "locust_subnet_cidr" {
    value = "${aws_subnet.public_subnet.cidr_block}"
}
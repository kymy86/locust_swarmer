output "master_ip" {
    value = "${aws_instance.locust_master.public_ip}"
}

output "master_web" {
    value = "http://${aws_instance.locust_master.public_ip}:8089"
}

output "slave_ips" {
    value = ["${aws_instance.locust_slave.*.public_ip}"]
}
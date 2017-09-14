variable "aws_region" {
    description = "AWS region where launch servers"
    default = "eu-west-1"
}

variable "aws_profile" {
    description = "aws profile"
    default = "default"
}

variable "aws_amis" {
    default = {
        eu-central-1 = "ami-1e339e71"
        eu-west-2 = "ami-996372fd"
        eu-west-1 = "ami-785db401"
    }
}

variable "locust_instance_type" {
    default = "t2.small"
}

variable "aws_public_key_path" {
    description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/locust.pub
DESCRIPTION
}

variable "aws_private_key_path" {
    description = <<DESCRIPTION
Path to the SSH private key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/locust.pem
DESCRIPTION
}

variable "aws_key_name" {
    description = "Name of the AWS key pair"
}

variable "ingress_allow_cidr" {
    description = "List of CIDR that are allow to connect to the instances"
    type = "list"
}

variable "locust_config_bucket_name" {
    description = "Name of bucket where the locust config file will be stored"
    default = "beprime-locust-config"
}

variable "locust_file_name" {
    description = "Name of locust file"
    default = "locustfile.py"
}

variable "number_of_slaves" {
    description = "Number of slave will be provisioned"
    default = "3"
}

variable "ssh_user" {
    description = "SSH User for slave instance"
    default = "ubuntu"
}

variable "swarmed_url" {
    description = "URL against what the Locust swarm will be run"
}
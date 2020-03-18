variable "aws_region" {
  description = "AWS region where servers will be launched"
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "aws profile"
}

variable "locust_instance_type" {
  default = "t3.small"
}

variable "aws_amis" {
    default = {
        eu-central-1 = "ami-0b418580298265d5c"
        eu-west-2 = "ami-006a0174c6c25ac06"
        eu-west-1 = "ami-035966e8adab4aaad"
    }
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
  description = "List of CIDRs that are allowed to connect to the instances"
  type        = list(string)
}

variable "locust_file_name" {
  description = "Name of locust file"
  default     = "locustfile.py"
}

variable "number_of_slaves" {
  description = "Number of slaves that will be provisioned"
  default     = "3"
}

variable "ssh_user" {
  description = "SSH user for slave instances"
  default     = "ubuntu"
}

variable "swarmed_url" {
  description = "URL against what the Locust swarm will be run"
}


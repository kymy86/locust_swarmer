provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_key_pair" "locust_auth" {
  key_name   = var.aws_key_name
  public_key = file(var.aws_public_key_path)
}

#create S3 bucket where saving the locust configuration files
resource "aws_s3_bucket" "locust_config_bucket" {
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.locust_config_bucket.id
  acl    = "private"
}

#uploads locust files
resource "aws_s3_bucket_object" "locust_config" {
  bucket = aws_s3_bucket.locust_config_bucket.bucket
  key    = var.locust_file_name
  source = "../locust_files/locustfile.py"
  etag   = filemd5("../locust_files/locustfile.py")
}

module "iam" {
  source     = "./iam"
  bucket_arn = aws_s3_bucket.locust_config_bucket.arn
}

module "network" {
  source = "./network"
}

module "security" {
  source             = "./security"
  vpc_id             = module.network.locust_vpc_id
  ingress_allow_cidr = var.ingress_allow_cidr
}

data "aws_ami" "aws_amis" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}

/*
* Instantiate master node
*/
resource "aws_instance" "locust_master" {
  ami                  = data.aws_ami.aws_amis.id
  instance_type        = var.locust_instance_type
  key_name             = var.aws_key_name
  security_groups      = [module.security.locust_sc_id]
  subnet_id            = module.network.locust_subnet_id
  iam_instance_profile = module.iam.es_iam_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp3"
    volume_size = "8"
  }

  user_data = templatefile(
    "${path.module}/user_data/init_master_server.tpl",
    {
      locust_config_bucket = aws_s3_bucket.locust_config_bucket.bucket
      locust_file_name     = var.locust_file_name
      swarmed_url          = var.swarmed_url
    }
  )

  tags = {
    Name = "Locust master instance"
  }
}

/*
* Instantiate slave nodes
*/
resource "aws_instance" "locust_slave" {
  count                = var.number_of_slaves
  ami                  = data.aws_ami.aws_amis.id
  instance_type        = var.locust_instance_type
  key_name             = var.aws_key_name
  security_groups      = [module.security.locust_sc_id]
  subnet_id            = module.network.locust_subnet_id
  iam_instance_profile = module.iam.es_iam_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp3"
    volume_size = "8"
  }

  user_data = templatefile(
    "${path.module}/user_data/init_slave_server.tpl",
    {
      locust_config_bucket = aws_s3_bucket.locust_config_bucket.bucket
      locust_file_name     = var.locust_file_name
      master_ip            = aws_instance.locust_master.public_ip
    }
  )

  tags = {
    Name = "Locust Slave instance #${count.index}"
  }
}
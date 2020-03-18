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
  acl    = "private"
  region = var.aws_region
}

#uploads locust files
resource "aws_s3_bucket_object" "locust_config" {
  bucket = aws_s3_bucket.locust_config_bucket.bucket
  key    = var.locust_file_name
  source = "../locust_files/locustfile.py"
  etag   = filemd5("../locust_files/locustfile.py")
}

module "iam" {
  source = "./iam"
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

/*
* Instantiate master node
*/
data "template_file" "init_server" {
  template = file("./user_data/init_master_server.tpl")
  vars = {
    locust_config_bucket = aws_s3_bucket.locust_config_bucket.bucket
    locust_file_name     = var.locust_file_name
    swarmed_url          = var.swarmed_url
  }
}

resource "aws_instance" "locust_master" {
  ami           = lookup(var.aws_amis, var.aws_region)
  instance_type = var.locust_instance_type
  key_name      = var.aws_key_name
  security_groups      = [module.security.locust_sc_id]
  subnet_id            = module.network.locust_subnet_id
  iam_instance_profile = module.iam.es_iam_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "8"
  }

  user_data = base64encode(data.template_file.init_server.rendered)

  tags = {
    Name = "Locust master instance"
  }
}

/*
* Instantiate slave nodes
*/

data "template_file" "init_server_slave" {
  template = file("./user_data/init_slave_server.tpl")
  vars = {
    locust_config_bucket = aws_s3_bucket.locust_config_bucket.bucket
    locust_file_name     = var.locust_file_name
    master_ip            = aws_instance.locust_master.public_ip
  }
}

resource "aws_instance" "locust_slave" {
  count         = var.number_of_slaves
  ami           = lookup(var.aws_amis, var.aws_region)
  instance_type = var.locust_instance_type
  key_name      = var.aws_key_name
  security_groups      = [module.security.locust_sc_id]
  subnet_id            = module.network.locust_subnet_id
  iam_instance_profile = module.iam.es_iam_id

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "8"
  }

  user_data = base64encode(data.template_file.init_server_slave.rendered)

  tags = {
    Name = "Locust Slave instance #${count.index}"
  }
}

data "template_file" "slave_provisioner" {
  template = file("./user_data/slave_provisioner.tpl")
  vars = {
    locust_config_bucket = aws_s3_bucket.locust_config_bucket.bucket
    locust_file_name     = var.locust_file_name
    master_ip            = aws_instance.locust_master.public_ip
  }
}

resource "null_resource" "provision_app" {
  triggers = {
    slaves_instance_ids = join(",", aws_instance.locust_slave.*.id)
  }
  count = var.number_of_slaves

  connection {
    type        = "ssh"
    host        = element(aws_instance.locust_slave.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file(var.aws_private_key_path)
    agent       = false
  }
  provisioner "remote-exec" {
    inline = [data.template_file.slave_provisioner.rendered]
  }
}


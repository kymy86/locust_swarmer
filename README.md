# Locust Swarmer

With this project You can provision a distributed [Locust]() Swarm on Amazon AWS by using Terraform.

- Provision the master node and N slaves node
- Copy the locustfile.py in the locust_files/ dir on a S3 bucket for replication in each slave node
- Surf to master node URL and execute the load tests

[Locust]:http://locust.io/

## Infrastructure provisioning: getting started

1. Customize the locustfile.py
2. In *provision_locust_nest* folder, run the Terraform commands to provision the infrastructure.

```
├── locust_files
│   └── locustfile.py
├── provision_locust_nest
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├──iam
│   ├──network
│   ├──security
│   ├──user_data
```

## Terraform configuration variable

- `aws_profile`: name of the AWS profile
- `aws_key_name`: name of the private key
- `aws_public_key_path`: absolute path of public key on your PC
- `aws_private_key_path`: absolute path of private key on your PC
- `ingress_allow_cidr`: list of CIDR block from where the SSH access to the instance is allowed.
- `swarmed_url`: URL of website subjected to the load testing
- `number_of_slaves`: define the number of locust slaves to provisioned. Default value is 3.
- `locust_file_name`: name of locust file in the locust_files directory. Default value is locustfile.py
# terraform-aws-documentdb-mongodb
Install MongoDB on AWS
[https://registry.terraform.io/modules/mrnim94/documentdb-mongodb/aws/latest](https://registry.terraform.io/modules/mrnim94/documentdb-mongodb/aws/latest)


## Provide VPC ID and subnet IDs via data sources: "aws_vpc and aws_subnets".


```hcl
data "aws_vpc" "selected" {
  tags = {
    Name = "dev-mdcl-mdaas-engine" # Replace with your VPC's tag name
  }
}

data "aws_subnets" "private_networks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}


module "documentdb-mongodb" {
  source  = "mrnim94/documentdb-mongodb/aws"
  version = "0.0.8"
  vpc_id = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private_networks.ids
  cluster_name = "mongodb"
  engine_version = "5.0.0"
  cluster_family = "docdb5.0"
  allow_major_version_upgrade = true
  retention_period = 35
  instance_type = "db.t3.medium"
  cluster_size = 1
  allowed_cidr_blocks = [data.aws_vpc.selected.cidr_block,"10.195.8.0/21"]
}
```

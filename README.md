## terraform-aws-documentdb-mongodb

Install MongoDB on AWS

Terraform Link:  
[https://registry.terraform.io/modules/mrnim94/documentdb-mongodb/aws/latest](https://registry.terraform.io/modules/mrnim94/documentdb-mongodb/aws/latest)

## Provide VPC ID and subnet IDs via data sources: "aws\_vpc and aws\_subnets".

### Get the existing VPC's information via Data Sources

```plaintext
data "aws_vpc" "selected" {
  tags = {
    Name = "dev-nim-engine" # Replace with your VPC's tag name
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
  version = "1.1.0"
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

### Get the VPC's information via Remote State.

```plaintext
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "backend-nim-integration-terraform"
    key    = "infra-structure/prod-nim-engines-uswest2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

module "documentdb-mongodb" {
  source  = "mrnim94/documentdb-mongodb/aws"
  version = "1.1.0"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
  cluster_name = "mongodb"
  engine_version = "5.0.0"
  cluster_family = "docdb5.0"
  allow_major_version_upgrade = true
  retention_period = 35
  instance_type = "db.t3.medium"
  cluster_size = 1
  allowed_cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr_block]
}
```

### Restore DocumentDB from a snapshot.

Obtain the specific Snapshot ARN from the old DocumentDB and enter it as the `snapshot_identifier`.

![](https://raw.githubusercontent.com/mrnim94/terraform-aws-documentdb-mongodb/sec-group-follow-db-name/docs/picture/2024-10-17_16-49.png)

You must know the Document's username to declare it in the Terraform module.

![](https://raw.githubusercontent.com/mrnim94/terraform-aws-documentdb-mongodb/sec-group-follow-db-name/docs/picture/2024-10-18_14-43.png)

```plaintext
....

module "documentdb-mongodb-restored" {
  source  = "mrnim94/documentdb-mongodb/aws"
  version = "1.1.0"
  vpc_id = data.aws_vpc.selected.id
  subnet_ids = data.aws_subnets.private_networks.ids
  cluster_name = "mongodb-restored"
  engine_version = "5.0.0"
  cluster_family = "docdb5.0"
  allow_major_version_upgrade = true
  retention_period = 35
  instance_type = "db.t3.medium"
  cluster_size = 1
  allowed_cidr_blocks = [data.aws_vpc.selected.cidr_block]
  snapshot_identifier = "arn:aws:rds:us-west-2:043701111869:cluster-snapshot:rds:mongodb-2024-10-12-03-13"
  master_username = "tarpon"
}
```

When creating a new DocumentDB from the completed snapshot, you must use a username and password to log in.

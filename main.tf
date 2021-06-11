# Save tfstate file in s3 bucket - uncomment and run terraform init  command
# terraform {
#   required_version = ">=0.12"
#   backend "s3" {
#     bucket = "myapp-bucket-for-tfstate" #bucket name in aws
#     key    = "myapp-bucket-for-tfstate/state.tfstate"
#     region = "us-east-2"
#   }
# }

provider "aws" {
    region = "us-east-2"
}

resource "aws_vpc" "myapp_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      "Name" = "${var.env_prefix}-vpc"
    }
}

module "myapp_subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
    vpc_id = aws_vpc.myapp_vpc.id
}

module "myapp_webserver" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp_vpc.id
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    instance_type = var.instance_type
    subnet_id = module.myapp_subnet.subnet.id
    avail_zone = var.avail_zone   
}
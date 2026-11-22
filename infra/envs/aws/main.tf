terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "tp-devops-p6"
      ManagedBy = "terraform"
    }
  }
}

locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  user_data = templatefile("${path.module}/../../cloud-init.yaml.tftpl", {
    hostname       = var.name
    ssh_user       = var.ssh_user
    ssh_public_key = local.ssh_public_key
  })
}

module "vm" {
  source = "../../modules/vm-aws"

  name             = var.name
  size             = var.size
  ssh_public_key   = local.ssh_public_key
  open_ports       = var.open_ports
  ssh_allowed_cidr = var.ssh_allowed_cidr
  ssh_user         = var.ssh_user
  user_data        = local.user_data
}

variable "aws_region" {}

variable "vpc_cidr_block" {}

variable "cluster_name" {}

variable "domain" {}

variable "networks" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "az_names" {
  type = list(string)
  default = [
    "ap-northeast-1a",
    "ap-northeast-1c",
  ]
}

variable "vpc_name" {
  type    = string
  default = "vpc-by-terraform"
}

variable "vpc_cidr" {
  type    = string
  default = "172.17.0.0/16"
}

# must match with "az_names"
variable "vpc_private_subnets" {
  type = list(string)
  default = [
    "172.17.1.0/24",
    "172.17.2.0/24",
  ]
}

# must match with "az_names"
variable "vpc_public_subnets" {
  type = list(string)
  default = [
    "172.17.11.0/24",
    "172.17.12.0/24",
  ]
}

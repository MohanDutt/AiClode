variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "aiclod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

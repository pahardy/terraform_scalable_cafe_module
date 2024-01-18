locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "http"
  all_ips = ["0.0.0.0/0"]
}

variable "region" {
  description = "The AWS region into which to deploy resources"
  type = string
  default = "ca-central-1"
}

variable "cafe-ami" {
  description = "The AMI on which to install the cafe app"
  type = string
  default = "ami-0a2e7efb4257c0907"
}

#Getting the default VPC ID and populating it in a variable
data "aws_vpc" "default-vpc" {
  default = true
}

#Getting the subnet IDs
data "aws_subnets" "asg-subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

variable "asg-max" {
  description = "Maximum ASG size"
  type = number
}

variable "asg-min" {
  description = "Minimum ASG size"
  type = number
}

variable "asg-desired" {
  description = "Desired ASG size"
  type = number
}

variable "http-port" {
  description = "Port for HTTP traffic"
  type = number
  default = 80
}

variable "cidr_blocks" {
  description = "CIDR block for the SGs"
  type = string
  default = "0.0.0.0/0"
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type = string
}
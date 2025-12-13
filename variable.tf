variable "deployHub_vpc_cidr_block" {
  description = "deployHub_vpc_cidr_block"
  type = string
}

variable "public_subnet_cide_block" {
  type = string
}

variable "public_subnet_availability_zone" {
   type = string
}

variable "private_subnet_cide_block" {
  type = string
}

variable "private_subnet_availability_zone" {
   type = string
}

variable "aws_instance_ami" {
  type = string
}

variable "aws_instance_type" {
  type = string
}

variable "aws_instance_key_pair" {
  type = string
}
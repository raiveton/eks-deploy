####### modules/vpc/variables.tf

variable "vpc_cidr" {}
variable "access_ip" {}
variable "public_sn_count" {}
variable "public_cidrs" {
  type = list(any)
}
variable "instance_tenancy" {

}
variable "tags" {

}
variable "map_public_ip_on_launch" {

}
variable "rt_route_cidr_block" {

}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
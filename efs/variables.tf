variable "private-subnet" {
    type = list(string)
}
variable "owner-name" {
  type = string
}
variable "cidr_allowing_all" {
  type = string
}
variable "vpcid" {
  type = string
}
variable "ec2-sg" {
  type = string
}
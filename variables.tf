variable "vpc-cidr" {
  type = string
}
variable "cidr-allowing-all" {
  type = string
}
variable "public-subnet-cidr" {
  type = map(object({
    cidr = string
    az = string
  }))
}
variable "private-subnet-cidr" {
  type = map(object({
    cidr = string
    az = string
  }))
}
variable "ownername" {
  type = string
}
variable "ec2_ami" {
  type = string
}
variable "asg_min_size" {
  type = string
}
variable "asg_max_size" {
  type = string
}
variable "asg_desired_capacity" {
  type = string
}
variable "ec2_type" {
  type = string
}
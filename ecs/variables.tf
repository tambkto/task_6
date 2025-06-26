variable "ec2_ami" {
  type = string
}
variable "owner_name" {
  type = string
}
variable "ec2_type" {
  type = string
}
variable "vpcid" {
  type = string
}
variable "alb_sg_id" {
  type = string
}
variable "cidr_allowing_all" {
  type = string
}
variable "instance_profile" {
  type = string
}
variable "efs_id" {
  type = string
}
variable "private_subnet" {
  type = list(string)
}
variable "target_group_arn" {
  type = list(string)
}
variable "target-group-arn" {
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
variable "ecs_task_execution_role_arn" {
  type = string
}
variable "alb-listener-http" {
  type = any
}
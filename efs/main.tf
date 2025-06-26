resource "aws_efs_file_system" "efs" {
  creation_token = "umar-efs"
  throughput_mode = "provisioned" //when we want to set the throughput according to our requirement
  provisioned_throughput_in_mibps = 1
  tags = {
    Name = "${var.owner-name}_efs" 
  }
}
resource "aws_efs_mount_target" "efs_mount_target" { //always pass list, it doesn't expect object
    count = length(var.private-subnet)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id = var.private-subnet[count.index]
  security_groups = [aws_security_group.efs_sg.id] //we should add SG of EC2 that is used in template.

}
resource "aws_security_group" "efs_sg" {
    vpc_id = var.vpcid
    name = "SG-efs${var.owner-name}"
    tags = {
        Name = "SG-efs${var.owner-name}"
    }
}
resource "aws_vpc_security_group_ingress_rule" "ingress" {
    security_group_id = aws_security_group.efs_sg.id
    from_port = 2049
    ip_protocol = "tcp"
    to_port = 2049
    referenced_security_group_id = var.ec2-sg     //attach SG of EC2 from template so it allows trafic from ec2-sg only
}
resource "aws_vpc_security_group_egress_rule" "egress" {
    security_group_id = aws_security_group.efs_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = var.cidr_allowing_all
}
# resource "aws_vpc_security_group_egress_rule" "egress" {
#     security_group_id = aws_security_group.efs_sg.id
#     ip_protocol = "-1"
#     cidr_ipv4 = var.cidr_allowing_all
# }

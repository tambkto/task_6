resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.owner_name}_cluster"
}
resource "aws_ecr_repository" "nginx_repo" {
  name = "umar/repo"
  force_delete = true
}
resource "null_resource" "push_nginx_to_ecr" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      set -e
      pwd
      ls -l ..
      aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.nginx_repo.repository_url}
      docker pull nginx:latest
      docker tag nginx:latest ${aws_ecr_repository.nginx_repo.repository_url}:latest
      docker push ${aws_ecr_repository.nginx_repo.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.nginx_repo] //ensures ecr repo is created before script runs
}
# data "aws_ssm_parameter" "ecs_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
# }
resource "aws_launch_template" "launch_template" {
  name = "${var.owner_name}_launch_template"
  image_id =  var.ec2_ami
  instance_type = var.ec2_type
  key_name = "umar-login"
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  iam_instance_profile {
    name = var.instance_profile
  }
 
  user_data = base64encode(templatefile("${path.root}/script.sh", {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    
  }))
  
}
resource "aws_autoscaling_group" "asg" {
  name = "${var.owner_name}_asg"
  vpc_zone_identifier = var.private_subnet
  target_group_arns = var.target_group_arn //variable type is list(strings)
  health_check_type = "ELB"
  health_check_grace_period = 900
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  launch_template {
    id = aws_launch_template.launch_template.id
    
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.owner_name}_task_definition"
  network_mode             = "bridge" //read about it
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 256
  execution_role_arn       = var.ecs_task_execution_role_arn
  
  volume { 
    name = "umar-efs" //use name from creation tag in efs
    efs_volume_configuration {
      file_system_id = var.efs_id
      transit_encryption = "ENABLED"
      root_directory = "/"
      authorization_config {
        iam = "DISABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name: "nginx",
      image: "${aws_ecr_repository.nginx_repo.repository_url}:latest",
      cpu: 512,
      memory: 256,
      essential: true,
      mountPoints = [{
        sourceVolume = "umar-efs" 
        containerPath  = "/mnt/efs"
      }
      ]
      portMappings: [
        {
          containerPort: 80,
          hostPort: 80,
        },
      ],
       logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cloudwatch_log_group.name
          awslogs-region        = "us-east-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
}
resource "aws_ecs_service" "service" {
  name             = "${var.owner_name}_service"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 3
  launch_type      = "EC2"

#   network_configuration {
#     security_groups  = [aws_security_group.sg_ec2.id]
#     subnets       = var.private_subnet  
#   }
  
  load_balancer { //here, we have registered target with LB
    target_group_arn = var.target-group-arn //variable type is string
    container_name = "nginx"
    container_port = 80
  }
  depends_on = [ var.alb-listener-http ]

  lifecycle {
    ignore_changes = [task_definition]
  }
  }

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.owner_name}_cloudwatch_log_group"
  retention_in_days = 7
}

resource "aws_security_group" "sg_ec2" {
  vpc_id      = var.vpcid
  name = "${var.owner_name}_ec2_sg"
  tags = {
    Name  = "${var.owner_name}_ec2_sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "ingress" {
    security_group_id = aws_security_group.sg_ec2.id
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
    referenced_security_group_id = var.alb_sg_id //only allows tarffic from port 80 from ALB
   
}
resource "aws_vpc_security_group_ingress_rule" "ingress1" {
    security_group_id = aws_security_group.sg_ec2.id
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
    cidr_ipv4 = var.cidr_allowing_all
}
resource "aws_vpc_security_group_egress_rule" "egress" {
    security_group_id = aws_security_group.sg_ec2.id
    ip_protocol = "-1"
    cidr_ipv4 = var.cidr_allowing_all
}
  


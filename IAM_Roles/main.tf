//task execution role for ecs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#IAM role  policy for pulling image from ecr
resource "aws_iam_role_policy_attachment" "ecs_execution_ecr" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "umar_ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_ssm_role" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}
#IAM role policy for EC2 to register with ECS
resource "aws_iam_role_policy_attachment" "ec2_instance_role_ecs_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
#IAM role policy for cloudwatch agent
resource "aws_iam_role_policy_attachment" "ec2_instance_role_cloudwatch_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy" "ec2_instance_efs_policy" {
  name = "role_policy_for_efs"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = "*"
      }
    ]
  })
}
#INSTANCE PROFILE IS created and is used to attach ec2 instance with ec2 role
resource "aws_iam_instance_profile" "instance_profile" {
  name = "umar-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}


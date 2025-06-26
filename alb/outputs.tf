output "aws_lb_target_group" {
  value = aws_lb_target_group.ip_tg_alb.arn
}
output "alb_listener_http" {
  value = aws_lb_listener.listener
}
output "alb_id" {
  value = aws_alb.alb.id
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
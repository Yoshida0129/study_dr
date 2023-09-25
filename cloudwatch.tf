resource "aws_cloudwatch_log_group" "nginx_test" {
  name              = "/ecs/project/nginx_test"
  retention_in_days = 30
}
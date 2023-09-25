data "aws_iam_policy_document" "cloudwatch_logs_allow_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
		]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_logs_allow_policy" {
  name        = "cloudwatch_logs_policy"
  path        = "/"
  description = ""
  policy      = data.aws_iam_policy_document.cloudwatch_logs_allow_policy.json
}

data "aws_iam_policy_document" "ecs_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_role_attachement" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_allow_policy.arn
}
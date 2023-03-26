resource "aws_cloudwatch_event_rule" "task_scheduler" {
  name                = "every_day_task"
  description         = "Schedule task to run daily"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_ecs_cluster" "tasks" {
  name = "tasks"
}

resource "aws_ecs_task_definition" "daily_task" {
  family = "daily_task"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024

  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name  = "daily_task",
      image = "python:3.11"
      command : [
        "python -V"
      ],
      cpu : 512,
      memory : 1024,
    }
  ])
}

data "aws_iam_policy_document" "task_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_events" {
  name               = "ecs_events"
  assume_role_policy = data.aws_iam_policy_document.task_policy.json
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ecs_events_run_task_with_any_role" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [replace(aws_ecs_task_definition.daily_task.arn, "/:\\d+$/", ":*")]
  }
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name   = "ecs_events_run_task_with_any_role"
  role   = aws_iam_role.ecs_events.id
  policy = data.aws_iam_policy_document.ecs_events_run_task_with_any_role.json
}

resource "aws_cloudwatch_event_target" "task_target" {
  target_id = "daily_ecs_task_schedule_target"
  rule      = aws_cloudwatch_event_rule.task_scheduler.name
  arn       = aws_ecs_cluster.tasks.arn
  role_arn  = aws_iam_role.ecs_events.arn
  #input =

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.daily_task.arn
  }
}

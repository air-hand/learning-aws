data "aws_iam_policy_document" "task_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_region" "current" {}

resource "aws_ecs_cluster" "tasks" {
  name = "tasks"
}

resource "aws_ecs_task_definition" "daily_task" {
  family = "daily_task"

  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024

  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "daily_task",
      image = "python:3.11"
      command : [
        "python -c 'import sys; import datetime; print(sys.version); print(datetime.datetime.now())'"
      ],
      cpu : 512,
      memory : 1024,
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-group : aws_cloudwatch_log_group.ecs_scheduled_task.name,
          awslogs-region : data.aws_region.current.name,
          awslogs-stream-prefix : "ecs",
        }
      }
    }
  ])
}

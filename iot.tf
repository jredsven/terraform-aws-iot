
resource "aws_timestreamwrite_database" "timestream" {
  database_name = var.database_name
}

resource "aws_timestreamwrite_table" "timestream" {
  database_name = aws_timestreamwrite_database.timestream.database_name
  table_name    = var.table_name
}

resource "aws_iot_thing" "rpi3" {
  name = var.iot_thing
}

resource "aws_iot_certificate" "cert" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.rpi3.name
}

data "aws_iam_policy_document" "iot" {
  statement {
    actions = [
      "iot:Publish",
      "iot:Receive",
      "iot:PublishRetain"
    ]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${var.topic_name}"]
  }
  statement {
    actions   = ["iot:Subscribe"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topicfilter/${var.topic_name}"]
  }
  statement {
    actions   = ["iot:Connect"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/test-*"]
  }
}

resource "aws_iot_policy" "pubsub" {
  name   = "PubSubToAnyTopic"
  policy = data.aws_iam_policy_document.iot.json
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.pubsub.name
  target = aws_iot_certificate.cert.arn
}

resource "aws_iam_role" "role" {
  name = "TimestreamRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      }
    ]
  })
}

resource "aws_iam_role_policy" "timestream" {
  name   = "timeStreamPolicy"
  role   = aws_iam_role.role.name
  policy = data.aws_iam_policy_document.timestream.json
}

data "aws_iam_policy_document" "timestream" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [aws_cloudwatch_log_group.log_group.arn]
  }
  statement {
    actions   = ["timestream:WriteRecords"]
    resources = [aws_timestreamwrite_table.timestream.arn]
  }
  statement {
    actions   = ["timestream:DescribeEndpoints"]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/iot/${var.iot_thing}"
  retention_in_days = 7
}

resource "aws_iot_topic_rule" "rule" {
  name        = "TimeStreamRule"
  description = "Export to Timestream"
  enabled     = true
  sql         = "SELECT * FROM '${var.topic_name}'"
  sql_version = "2016-03-23"

  timestream {
    database_name = aws_timestreamwrite_database.timestream.database_name
    table_name    = aws_timestreamwrite_table.timestream.table_name
    dimension {
      name  = "device_id"
      value = "$${ClientID()}"
    }
    role_arn = aws_iam_role.role.arn
  }

  error_action {
    cloudwatch_logs {
      batch_mode     = false
      log_group_name = aws_cloudwatch_log_group.log_group.name
      role_arn       = aws_iam_role.role.arn
    }
  }
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role_increment_visits" {
  name               = "lambda_execution_role_increment_visits"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "allow_ddb_writes" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visits.arn]
  }
}

resource "aws_iam_policy" "allow_ddb_writes" {
  name   = "allow_ddb_writes"
  policy = data.aws_iam_policy_document.allow_ddb_writes.json
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda_execution_role_increment_visits.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ddb_writes" {
  role       = aws_iam_role.lambda_execution_role_increment_visits.name
  policy_arn = aws_iam_policy.allow_ddb_writes.arn
}

# Package the Lambda function code
data "archive_file" "increment_visits" {
  type        = "zip"
  source_file = "${path.module}/lambda/increment_visits/index.mjs"
  output_path = "${path.module}/lambda/increment_visits/index.zip"
}

# Lambda function
resource "aws_lambda_function" "increment_visits" {
  filename      = data.archive_file.increment_visits.output_path
  function_name = "incrementVisits"
  role          = aws_iam_role.lambda_execution_role_increment_visits.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.increment_visits.output_base64sha256

  runtime = "nodejs20.x"

  tags = var.tags
}

// Lambda function: getVisits()
resource "aws_iam_role" "lambda_execution_role_get_visits" {
  name               = "lambda_execution_role_get_visits"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "allow_ddb_reads" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.visits.arn]
  }
}

resource "aws_iam_policy" "allow_ddb_reads" {
  name   = "allow_ddb_reads"
  policy = data.aws_iam_policy_document.allow_ddb_reads.json
}

resource "aws_iam_role_policy_attachment" "ddb_reads" {
  role       = aws_iam_role.lambda_execution_role_get_visits.name
  policy_arn = aws_iam_policy.allow_ddb_reads.arn
}

resource "aws_iam_role_policy_attachment" "get_visits_logs" {
  role       = aws_iam_role.lambda_execution_role_get_visits.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "get_visits" {
  type        = "zip"
  source_file = "${path.module}/lambda/get_visits/index.mjs"
  output_path = "${path.module}/lambda/get_visits/index.zip"
}

resource "aws_lambda_function" "get_visits" {
  filename      = data.archive_file.get_visits.output_path
  function_name = "getVisits"
  role          = aws_iam_role.lambda_execution_role_get_visits.arn
  handler       = "index.handler"
  code_sha256   = data.archive_file.get_visits.output_base64sha256

  runtime = "nodejs20.x"

  tags = var.tags
}

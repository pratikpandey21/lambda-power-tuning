# This block configures the AWS provider.
# The profile and region are set to the values that were passed to the Terraform CLI.
provider "aws" {
  profile = "prof-acc"
  region = "us-east-1"
}

# This block defines the required providers for the Terraform configuration.
# The AWS provider is required, and the version is specified.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This block creates a Lambda function.
# The function name, role, memory size, filename, source_code_hash, handler, and runtime are specified.
resource "aws_lambda_function" "compute_intensive" {
  function_name = "compute_intensive"
  role = aws_iam_role.iam_for_lambda.arn
  memory_size = 128

  filename = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler = "compute_intensive"
  runtime = "go1.x"
}

# This block defines an IAM policy document.
# The policy allows the Lambda function to assume the IAM role that is created in the next block.
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

# This block defines an IAM policy document.
# The policy allows the Lambda function to write logs to CloudWatch.
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

# This block creates an IAM policy.
# The policy is based on the data that was defined in the previous block.
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

# This block attaches the IAM policy for lambda logging to the IAM role.
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# This block creates an IAM role.
# The role is used by the Lambda function to assume the IAM role that is created in the next block.
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# This block creates a CloudWatch log group.
# The log group is used to store the logs for the Lambda function, which can be used for debugging.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/compute_intensive"
  retention_in_days = 1
}

# This block defines an archive file.
# The archive file is used to create the Lambda function.
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "build/bin/compute_intensive"
  output_path = "build/bin/compute_intensive.zip"
}

# This block creates a CloudFormation stack.
# The stack deploys the AWS Lambda Power Tuning tool.
resource "aws_serverlessapplicationrepository_cloudformation_stack" "lambda-power-tuning" {
  name             = "lambda-power-tuner"
  application_id   = "arn:aws:serverlessrepo:us-east-1:451282441545:applications/aws-lambda-power-tuning"
  capabilities     = ["CAPABILITY_IAM"]
  # Uncomment the next line to deploy a specific version
  # semantic_version = "4.3.1"

  parameters = {
    # All of these parameters are optional and are only shown here for demonstration purposes
    # See https://github.com/alexcasalboni/aws-lambda-power-tuning/blob/master/README-INPUT-OUTPUT.md#state-machine-input-at-deployment-time
    PowerValues           = "128,192,256,512,1024,2048,3072"
    lambdaResource        = "*"
    totalExecutionTimeout = 900
    visualizationURL      = "https://lambda-power-tuning.show/"
  }
}

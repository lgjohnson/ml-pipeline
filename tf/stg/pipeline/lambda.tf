# Lambda that triggers model retraining

#lambda function
resource "aws_lambda_function" "training_lambda" {
    function_name = "${local.training_lambda_function_name}"
    handler = "train_trigger.handler"
    runtime = "nodejs10.x"
    s3_bucket = "${aws_s3_bucket.lambdas_bucket.bucket}"
    s3_key = "lambda/train_trigger.zip"
    role = "${aws_iam_role.training_lambda_exec_role.arn}"
    depends_on = [
        "aws_iam_role_policy_attachment.lambda_logs",
        "aws_cloudwatch_log_group.lambda_log_cloudwatch"
    ]
}

#IAM role for lambda function
resource "aws_iam_role" "training_lambda_exec_role" {
    name = "lgjohnson_ml_pipeline_training_lambda_${var.stack_env}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

#cloudwatch log group for lambda function
resource "aws_cloudwatch_log_group" "lambda_log_cloudwatch" {
    name = "/aws/lambda/${var.stack_env}/${local.training_lambda_function_name}"
    retention_in_days = 14
}

#iam policy for logging
resource "aws_iam_policy" "lambda_logging" {
    name = "lambda_logging_${var.stack_env}"
    path = "/"
    description = "IAM policy for logging from lambda in ${var.stack_env}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

#attach logging policy to lambda iam policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = "${aws_iam_role.training_lambda_exec_role.name}"
    policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

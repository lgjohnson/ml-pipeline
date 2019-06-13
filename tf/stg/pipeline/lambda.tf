# LAMBDA FUNCTION

data "aws_s3_bucket" "lambdas_bucket" {
    bucket = "lgjohnson-ml-pipeline-lambda"
}

#lambda function
resource "aws_lambda_function" "training_lambda" {
    function_name = "${local.training_lambda_function_name}"
    handler = "train_trigger.handler"
    runtime = "nodejs10.x"
    
    s3_bucket = "${data.aws_s3_bucket.lambdas_bucket.bucket}"
    s3_key = "lambda/train_trigger.zip"

    timeout = 10

    role = "${aws_iam_role.training_lambda_exec_role.arn}"
    depends_on = [
        "aws_iam_role_policy_attachment.lambda_logs",
        "aws_cloudwatch_log_group.lambda_log_cloudwatch"
    ]
}

#permission for s3 to invoke lambda function
resource "aws_lambda_permission" "lambda_s3_permission" {
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.training_lambda.function_name}"
    principal = "s3.amazonaws.com"
    statement_id = "AllowS3AccessForTrainingLambda"
    source_arn = "${aws_s3_bucket.training_bucket.arn}"
}

#s3 bucket configuration - trigger for lambda function

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = "${aws_s3_bucket.training_bucket.id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.training_lambda.arn}"
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "training_data"
        filter_suffix       = ".jpg"
    }
}





#S3 ACCESS

#iam role for lambda function
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
            "Effect": "Allow"
        }
    ]
}
EOF
}

#iam policy for s3 access
resource "aws_iam_policy" "training_lambda_s3_access" {
    name = "training_lambda_s3_access_${var.stack_env}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.training_bucket.bucket}/*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

#attach s3 policy to lambda iam role

resource "aws_iam_role_policy_attachment" "lambda_s3" {
    role = "${aws_iam_role.training_lambda_exec_role.name}"
    policy_arn = "${aws_iam_policy.training_lambda_s3_access.arn}"
}





#LOGGING

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
            "Resource": [
                "arn:aws:logs:*:*:log-group:*:*:*",
                "arn:aws:logs:*:*:log-group:*"
            ],
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
EOF
}

#attach logging policy to lambda iam role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role = "${aws_iam_role.training_lambda_exec_role.name}"
    policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

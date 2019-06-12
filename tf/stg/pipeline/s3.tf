#s3 bucket for ml pipeline lambdas
resource "aws_s3_bucket" "lambdas_bucket" {
  bucket = "lgjohnson-ml-pipeline-lambda-${var.stack_env}"
  acl    = "private"
}

#s3 bucket for training data
resource "aws_s3_bucket" "training_bucket" {
    bucket  = "lgjohnson-ml-pipeline-training-${var.stack_env}"
    acl     = "private"

    versioning {
        enabled = true
    }

    logging {
        target_bucket = "${aws_s3_bucket.log_bucket.id}"
        target_prefix = "log/"
    }

    tags = {
        Environment = "Staging"
    }
}

#s3 bucket for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "lgjohnson-ml-pipeline-logs-${var.stack_env}"
  acl    = "log-delivery-write"
}
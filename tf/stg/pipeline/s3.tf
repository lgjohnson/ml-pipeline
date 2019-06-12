#s3 bucket for training data
data "aws_s3_bucket" "log_bucket" {
  bucket = "lgjohnson-ml-pipeline-logs"
}

resource "aws_s3_bucket" "training_bucket" {
    bucket  = "lgjohnson-ml-pipeline-training-${var.stack_env}"
    acl     = "private"

    versioning {
        enabled = true
    }

    logging {
        target_bucket = "${data.aws_s3_bucket.log_bucket.id}"
        target_prefix = "log/"
    }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

    tags = {
        Environment = "Staging"
    }
}
resource "aws_s3_bucket" "log_bucket" {
  bucket = "lgjohnson-ml-pipeline-logs"
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "training_bucket" {
    bucket  = "lgjohnson-ml-pipeline-training"
    acl     = "private"

    versioning {
        enabled = true
    }

    logging {
        target_bucket = "${aws_s3_bucket.log_bucket.id}"
        target_prefix = "log/"
    }

    tags = {
        Environment = "Production"
    }
}
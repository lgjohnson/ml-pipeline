#s3 bucket for ml pipeline lambdas
resource "aws_s3_bucket" "lambdas_bucket" {
  bucket = "lgjohnson-ml-pipeline-lambda"
  acl    = "private"
}

#s3 bucket for logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "lgjohnson-ml-pipeline-logs"
  acl    = "log-delivery-write"
}
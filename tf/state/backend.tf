provider "aws" {
    region = "us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "lgjohnson-ml-pipeline-tfstate"
    versioning {
        enabled = true
    }
    lifecycle {
        prevent_destroy = true
    }
}
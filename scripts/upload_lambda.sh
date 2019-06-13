#!/usr/bin/env bash
set -eo pipefail

# Usage:
#   zips and uploads a lambda job to S3
#   LAMBDA_S3_BUCKET must match the name of the bucket that lambda jobs are uploaded to
# Example:
#   ./upload_lambda.sh


# The following vars must match the s3uri used in the pipeline lambda terraform
LAMBDA_S3_BUCKET=lgjohnson-ml-pipeline-lambda
LAMBDA_S3_KEY=lambda/train_trigger.zip

# constants
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" #abs location of this script
TEMP_ZIP=/tmp/train_trigger.zip
LAMBDA_S3_URI="s3://${LAMBDA_S3_BUCKET}/${LAMBDA_S3_KEY}"

echo "zipping lambda function."
zip -q -j -r $TEMP_ZIP "${DIR}/train_trigger.js"

echo "uploading lambda function to ${LAMBDA_S3_URI}."
aws s3 cp --quiet $TEMP_ZIP $LAMBDA_S3_URI
rm $TEMP_ZIP

echo "lambda function uploaded."

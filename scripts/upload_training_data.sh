#!/usr/bin/env bash
set -eo pipefail

# Usage:
#   uploads a jpg image to the training bucket, triggering the lambda job
#   specify the environment and the path to the image as respective arguments
# Example:
#   ./upload_training_data.sh stg path/to/image.jpg

STACK_ENV=$1
IMAGE_PATH=$2
FILENAME=$(basename $IMAGE_PATH)

S3_TRAINING_BUCKET="lgjohnson-ml-pipeline-training-${STACK_ENV}"
S3_TRAINING_PREFIX="training_data"
LAMBDA_S3_URI="s3://${S3_TRAINING_BUCKET}/${S3_TRAINING_PREFIX}/${FILENAME}"

aws s3 cp --quiet $IMAGE_PATH $LAMBDA_S3_URI

echo "${FILENAME} successfully uploaded to ${LAMBDA_S3_URI}."

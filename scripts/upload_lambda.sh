#!/usr/bin/env bash
set -eo pipefail

# Usage:
#   zips and uploads a lambda job to S3
#   LAMBDA_S3_BUCKET must match the name of the bucket that lambda jobs are uploaded to
# Example:
#

#explicitly catch if STACK_ENV is undefined
if [[ -z "${STACK_ENV}" ]]; then
  echo ERROR: STACK_ENV not defined. This script should only be run by a Makefile through which STACK_ENV will be defined.
  exit 1
fi

#zip up lambda function and upload to S3
TEMP_ZIP=/tmp/train_trigger.zip
LAMBDA_S3_BUCKET=lgjohnson-ml-pipeline-lambda-${STACK_ENV}
LAMBDA_S3_URI=s3://${LAMBDA_S3_BUCKET}/lambda/train_trigger.zip

zip -r $TEMP_ZIP train_trigger.js
aws s3 cp $TEMP_ZIP $S3_URI
rm $TEMP_ZIP

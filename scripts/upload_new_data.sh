#!/usr/bin/env bash
set -eo pipefail

# Usage:
#   uploads new data to the ml-pipeline training bucket with the purpose of triggering retraining
#   specifically, uploads CSV for the year 2008
#   more info here: http://stat-computing.org/dataexpo/2009/the-data.html
#   takes one mandatory argument, the environment: "stg" or "prod"
# Example:
#   ./upload_new_data.sh stg

STACK_ENV=$1

S3_TRAINING_BUCKET="lgjohnson-ml-pipeline-training-${STACK_ENV}"
S3_TRAINING_PREFIX="training_data"
LAMBDA_S3_URI="s3://${S3_TRAINING_BUCKET}/${S3_TRAINING_PREFIX}"

TEMP_FOLDER="/tmp"
TIMESTAMP=$(date -u +"%Y%m%d%H%M")
YEAR=2008

DOWNLOAD_URL="http://stat-computing.org/dataexpo/2009/${YEAR}.csv.bz2"
curl -s $DOWNLOAD_URL -o "${TEMP_FOLDER}/new.csv.bz2"
bzip2 --force -d "${TEMP_FOLDER}/new.csv.bz2"
aws s3 cp --quiet "${TEMP_FOLDER}/new.csv" "${LAMBDA_S3_URI}/${TIMESTAMP}.csv"
echo "new data was successfully uploaded to ${LAMBDA_S3_URI}/${TIMESTAMP}.csv"

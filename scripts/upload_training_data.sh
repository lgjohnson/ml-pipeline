#!/usr/bin/env bash
set -eo pipefail

# Usage:
#   uploads "Reporting Carrier On-Time Performance" dataset to the ml-pipeline training bucket
#   specifically, uploads separates CSVs for the years 1987 to 2007
#   more info here: http://stat-computing.org/dataexpo/2009/the-data.html
#   takes one mandatory argument, the environment: "stg" or "prod"
# Example:
#   ./upload_training_data.sh stg

STACK_ENV=$1

S3_TRAINING_BUCKET="lgjohnson-ml-pipeline-training-${STACK_ENV}"
S3_TRAINING_PREFIX="training_data"
LAMBDA_S3_URI="s3://${S3_TRAINING_BUCKET}/${S3_TRAINING_PREFIX}"

TEMP_FOLDER="/tmp"
START_YEAR=1987
END_YEAR=2007

for YEAR in $(seq $START_YEAR $END_YEAR)
    do
        DOWNLOAD_URL="http://stat-computing.org/dataexpo/2009/${YEAR}.csv.bz2"
        curl -s $DOWNLOAD_URL -o "${TEMP_FOLDER}/${YEAR}.csv.bz2"
        bzip2 --force -d "${TEMP_FOLDER}/${YEAR}.csv.bz2"
        aws s3 cp --quiet "${TEMP_FOLDER}/${YEAR}.csv" "${LAMBDA_S3_URI}/${YEAR}.csv"
        echo "data for the year ${YEAR} was successfully uploaded to ${LAMBDA_S3_URI}/${YEAR}.csv"
    done

echo "all training data successfully uploaded"


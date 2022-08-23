#!/usr/bin/env bash
#
# Example using aws cli to query csv in bucket

bucket=$(terraform -chdir='../deploy' output --raw bucket)


# Example: first 10 records where FacilityType = 'Truck'
# Note: apparently the value in the WHERE statement must be single quoted

aws s3api select-object-content --bucket $bucket --key foodtrucks.csv \
  --expression "SELECT * FROM s3object s WHERE FacilityType = 'Truck' LIMIT 10" \
  --expression-type "SQL" \
  --input-serialization '{"CSV": {"FileHeaderInfo": "Use"}, "CompressionType": "NONE"}' \
  --output-serialization '{"CSV": {}}' \
  /dev/stdout

# This just shows you the headers

# aws s3api select-object-content --bucket $bucket --key foodtrucks.csv \
#   --expression "SELECT * FROM s3object s LIMIT 1" \
#   --expression-type 'SQL' \
#   --input-serialization '{"CSV": {"FileHeaderInfo": "NONE"}, "CompressionType": "NONE"}' \
#   --output-serialization '{"CSV": {}}' \
#   /dev/stdout

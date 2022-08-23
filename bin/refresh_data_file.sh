#!/usr/bin/env bash
# use curl to pull the foodtrucks csv and push to our s3 bucket

# --raw removes wrapping quotes from output
bucket=$(terraform -chdir='../deploy' output --raw bucket)

curl https://data.sfgov.org/api/views/rqzj-sfat/rows.csv | \
  aws s3 cp - s3://${bucket}/foodtrucks.csv

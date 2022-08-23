#!/usr/bin/env bash
#
# There is a chicken/egg problem with initial setup: the lambda has to be
# packaged before it can be deployed by terraform, otherwise terraform will
# error.
# 
# This script provides the operations in the right order to enable
# that initial setup. It can be run again later, but know that it will 
# repackage the lambda function and update the food trucks datafile on each
# run.

# First package the lambda function
./package_lambda.sh

# Make sure the TF env is init'd
cd ../deploy
terraform init

# Next run terraform
terraform apply

# Finally run the script that updates the datafile in s3
cd ../bin
./refresh_data_file.sh

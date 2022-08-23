#!/usr/bin/env bash
#
# Terraform takes lamdas as zip files, so lets make some

cd ../src
zip ../dist/food_trucks_lambda.zip lambda_function.py s3query/s3select.py

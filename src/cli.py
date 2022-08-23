#!/usr/bin/env python3
"""
CLI demo for querying data in a csv file in an s3 bucket
"""
import argparse

import json
import os
import sys

from s3query import s3select

my_parser = argparse.ArgumentParser(
        description="Query an s3 object using sql WHERE's")

my_parser.add_argument('--bucket', type=str, help='bucket name')
my_parser.add_argument('--key', type=str, help='object(key) name')
my_parser.add_argument('--region', type=str, help='AWS region for bucket')
my_parser.add_argument('--query', type=str,
        help="SQL Query which must be quoted. Example: WHERE FacilityType = 'Truck' LIMIT 10")

args = my_parser.parse_args()

bucket = args.bucket
key    = args.key
region = args.region
query  = args.query

sql_exp = ("SELECT * FROM s3object s "+ query)
output = s3select.query(bucket, key, region, sql_exp)

print(json.dumps(output))

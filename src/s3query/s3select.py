"""
s3select module

Common functions used for demo app querying s3 objects with SQL
"""

import csv
import json
import os

import boto3

# bucket, object, region = get_bucket_object_and_region()

def query(bucket, key, region, sql_exp):
    """
    Query sends the query to S3 and handles the response.

    Parameters:
    bucket:     name of bucket holding data
    key:        name of key (object) holding data
    region:     region where bucket is resident
    sql_exp:    SQL query to use against the bucket/key

    Returns:
    dict: Result of query
    """
    
    output = []
    
    client = boto3.client('s3', region_name=region)
    
    # enable querying by column headers
    use_header = True
    
    # run query
    resp = client.select_object_content(
        Bucket=bucket,
        Key=key,
        Expression=sql_exp,
        ExpressionType='SQL',
        InputSerialization={ "CSV": { 'FileHeaderInfo': 'USE', }, },
        OutputSerialization={ 'JSON': {} },
    )
    
    # S3 select_object_content returns a botocore.eventstream.EventStream
    # object which must then be processed
    for event in resp['Payload']:
        if 'Records' in event:
            record = event['Records']['Payload'].decode('utf-8')
            # records are delimited by something other than \n, but I don't
            # know what, possibly the \x1e record separator character. Fortunately, 
            # str.splitlines() handles it.
            records = record.splitlines()
    
    for item in records:
        output.append(json.loads(item))
    
    return(output)

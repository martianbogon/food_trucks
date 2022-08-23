"""
Lambda function for querying data in a csv file in s3

"""

import json
import os

from s3query import s3select

def get_bucket_key_region():
    """
    Function to get bucket, key, and region from env
    """

    bucket = os.environ.get('BUCKET')
    key    = os.environ.get('KEY')
    region = os.environ.get('AWS_REGION')

    return bucket, key, region

def lambda_handler(event, context):
    """
    Lamda handler event

    Arguments:
    event (object):   Event dict used to trigger the lambda
                      (for instance from API gateway)
    context (object): Context object passed to the Lambda handler

    Returns: Lambda response object
    """

    # These are configured via env vars in the function
    # definition or the local environment.
    bucket, key, region = get_bucket_key_region()


    # load event body into json
    # Example of query: "WHERE FacilityType = 'Truck' LIMIT 5"
    body = json.loads(event['body'])
    query = body['query']

    sql_exp = "SELECT * FROM s3object s " + query
    output = s3select.query(bucket, key, region, sql_exp)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(output)
    }

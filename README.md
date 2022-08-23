# Food Truck Demo
Demo using S3Select to query data in a CSV of food truck licensees from the
City of San Francisco.

(Data from: https://data.sfgov.org/api/views/rqzj-sfat/rows.csv)

## Summary
I've been wanting to play with S3 Select, which is a facility provided by AWS
to allow SQL-style queries against structed data in S3. This seemed like the 
perfect opportunity to give that a test drive.

My original concept was to use it in a Lambda to provide a query facility
via a REST API. This (mostly) works now, for POST requests at least. If I had
more time I'd do a lot more work on the API gateway portion, including auth and 
other operations, but the infrastructure is laid out and ready for improvement.

The actual SQL querying against S3 works great, but is maybe not super 
performant in my limited testing. I think this looks like a great way to enable
adhoc querying against cheaply stored structured data. It's pretty cool.

The project is 100% deployed to AWS via Terraform. I used an admin-enabled
user in testing. See Environment Setup and Teardown below.

# Parts
## Infrastructure with Terraform
In the deploy directory is all the terraform code. It has 3 modules:
1. **s3**: to configure the s3 bucket
2. **lambda**: to configure and deploy a lambda which can be used to query the
   data in s3
3. **api_gateway**: Lays out an API gateway instance which can send requests
   to the lambda

## Python code
In the src directory is the python code. At the root of that directory are two
.py files, once for a demo cli, and one for lambda. Both use a module in the
s3query directory.

## Utilities
In the bin directory are some shell scripts:
1. **deploy.sh**: convenience wrapper for terraform apply
2. **destroy.sh**: convenience wrapper for terraform destroy
3. **initial_setup.sh**: set up initial environment, solving a chicken/egg
   problem where the lambda function must first be created
1. **package_lambda.sh**: packages up the lambda in a zip file and puts it in
   dist, where terraform can pick it up
2. **refresh_data_file.sh**: used to pull the latest data file from San
   Francisco, and push it to the s3 bucket configured by terraform. Note that
   this queries terraform state to find the bucket.
3. **s3select_example.sh**: a quick shell script I used while learning to use 
   s3select.

## Dist
The dist directory exists just to catch the zip file with the lambda function
so that terraform can find it and upload it on terraform apply/

## Python development
Python source code is in the src directory. I develop using virtual env. To set
up your dev env like mine:
1. Make sure python3 is installed and up to date
2. In the root of this repo, type `python -m venv venv` to creat the venv.
3. Activate the venv with `source ./venv/bin/activate`
4. Install requirements: `cd src; pip install -r requirements.txt`

## Environment setup and teardown
### Setup
**NOTE**: You need credentials set up locally with rights to create all the 
infrastructure. In my dev account I have an IAM user with admin rights, but a
sensible thing to do in production would be to set up a specific IAM role so
it could be used with things like a CI/CD pipeline.

**Also NOTE**: By default the terraform is configured to use US-EAST-2 for all
resources. This can be overridden.

Once your python dev env is set up, you can use terraform to create the
infrastructure. From the deploy directory, run `terraform plan` to see what 
cloud resources will be created, and `terraform apply` to actually create them.
The output will tell you the s3 bucket and other resources that have been
created.

After running terraform apply, use `bin/refresh_data_file.sh` to put the data
file in the s3 bucket.

### Teardown
`terraform destroy` should clean up all the AWS resources. Note that the s3
bucket has `force_destroy` enabled to allow this. Without that param, terraform
would error and fail to destroy the bucket. Obviously this may or may not be a
good idea in production, depending on data retention requirements, but it is
safe here.

## Testing
### Testing with CLI
The python cli is the easiest way to demo s3select against the test data set.
Example:
```
./cli.py --bucket tyderia-foodtruck-bucket-20220728160047675000000001 \
          --key foodtrucks.csv --region us-east-2 \
          --query "WHERE FacilityType = 'Truck' LIMIT 5"
```
This will return the first 5 records with FacilityType "Truck".

To make the output pretty, you could pipe the output of that command to jq.

### Testing the API Gateway and Lambda
1. In the API Gateway area of the AWS console find the rest_api (named
   /foodtrucks). Click on the POST method, then click "TEST".
2. For the Request Body, use 
   `{ "query": "WHERE FacilityType = 'Truck' LIMIT 5" }'
3. Check the reponse body, you should see jsonified records from the CSV.


## TODOs
### API Gateway
The API gateway works in test mode, but there's more work to do to make it
trully production ready, like implementing auth and stages. This was best I
could do in a few hours.

### Lambda Function
It only handles POSTs right now, but with some work could use GETs with query
strings as well. Most of that work is in the lambda function.

### Testing
I spent quite a bit of time trying to get python-lambda-local to work
simulating the lambda service, but it doesn't seem to do a great job of
simulating lambda-proxy requests (like those that come from api gateway).
If I had more time, I'd try to figure that out.

Also unit tests for the python would be a very good idea too. :-)

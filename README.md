# Deploying Atlassian Jira with CloudFormation

## Prerequisites Notes
The Security Group IP address is open by default (testing purpose). Update the Security Group Access with your own IP Address to ensure your instances security.

Before you can deploy this process, you need the following:
 - Amazon EC2 key pair
 - Domain in Route 53.
 - ACM Certificate
 - S3 Bucket

![infrastructure-overview](https://d1.awsstatic.com/partner-network/QuickStart/datasheets/jira-on-aws-architecture.dd53a01a100d5c669246d65d948878798b71148a.png)

The repository consists of a set of nested templates that deploy the following:

 - A VPC with public and private subnets, spanning an AWS region.
 - A RDS PostgreSQL/MySQL with Multi-AZ or Amazon Aurora
 - Two NAT gateways to handle outbound traffic.
 - An ALB to the public subnets to handle inbound traffic.
 - Jira Application

## Templates Structure 

The templates below are included in this repository and reference architecture:

| Template | Description |
| --- | --- | 
| [templates/quickstart-jira-dc-with-vpc.template.yaml](templates/quickstart-jira-dc-with-vpc.template.yaml) | This is the master template - deploy it to CloudFormation and it includes all of the nested templates automatically. |
| [templates/quickstart-jira-dc.template.yaml](templates/quickstart-jira-dc.template.yaml) | This template will create ALB, ASG, EFS, RDS, EC2, etc.. The Jira DC will be placed in EC2 and CFN will run Ansible to download/install/configure Jira Application.
| [templates/quickstart-vpc-for-atlassian-services.yaml](templates/quickstart-vpc-for-atlassian-services.yaml) | This template deploys a VPC with a pair of public and private subnets spread across two Availability Zones. It deploys an [Internet gateway](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Internet_Gateway.html), with a default route on the public subnets. It deploys 2 [NAT gateways](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/vpc-nat-comparison.html), and default routes for them in the private subnets, and Bastion Host to access the instances in Private subnets. |
| [templates/quickstart-database-for-atlassian-services.yaml](templates/quickstart-database-for-atlassian-services.yaml) | This template deploys a Amazon Aurora PostgreSQl or RDS PostgreSQl/MySQL based on your condition. |
| [templates/aurora_postgres.template.yaml](templates/aurora_postgres.template.yaml) | This template deploys Amazon Aurora PostgreSQL. |
| [templates/quickstart-rds-for-atlassian-services.yaml](templates/quickstart-rds-for-atlassian-services.yaml) | This template deploys a RDS PostgreSQl or MySQL based on your condition. |

After the CloudFormation templates have been deployed, the [stack outputs](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html) contain a link to the site URLs.

## How to deploy

You can launch this CloudFormation stack in your account:

1. Checkout the code, make your own changes in [params/params.init](params/params.ini) and make the prerequisites updates.
 - Create Amazon EC2 key pair (If you want to deploy Bastion Host)
 - Create a domain in Route 53 (If you want to use your own domain.)
 - Create an ACM certificate (If you want to use your own certs)
 - Create S3 Bucket to store CFN templates.

2. Need to have [AWS CLI](aws.amazon.com/cli) in your laptop.

3. Upload the files in the "templates" directory into to your own S3 bucket.
```sh
$ AWS_PROFILE=<YOUR_AWS_PROFILE> BUCKET_NAME=<YOUR_S3_BUCKET> make init
```

4. Deploy the stacks
```sh
$ AWS_PROFILE=<YOUR_AWS_PROFILE> STACK_NAME=<STACK_NAME> BUCKET_NAME=<YOUR_S3_BUCKET> make create-stacks
```

## Author

Jason Dang
 - [dangphuc1302@gmail.com](dangphuc1302@gmail.com)

# Janice Zhong Resume IaC

Infrastructure-as-code for the Janice Zhong Resume project.

## DynamoDB

The DB has `id`(S) as primary key and `visitCount`(N) as an attribute.

## ACM

Separate certs for CloudFront and API Gateway.

## Features

- Terraform state is stored in a remote S3 bucket with locking enabled.
- Multi env

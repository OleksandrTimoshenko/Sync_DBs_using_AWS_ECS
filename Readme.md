# Creating Infrastructure for Sync PostgreSQL DBs using AWS ECS Tasks

## Requirements
1. Active AWS account
2. AWS CLI tool installed
3. Docker registry exists (This tutorial does not include setting up keys for Docker Registry in AWS ECS, assuming that the image will be public.)

## Setup Infrastructure
1. Build container - `docker build -t <YOUR_REGISTRY/IMAGE:TAG> ./`
2. Push to Docker registry - `docker push <YOUR_REGISTRY/IMAGE:TAG>`
3. Go to AWS and create an ECS cluster - `aws ecs create-cluster --cluster-name <YOUR_AWS_CLUSTER_NAME>`
4. Create a CloudWatch log group: `aws logs create-log-group --log-group-name <YOUR_AWS_LOG_GROUP_NAME>`
5. Create an AWS task definition: check the `aws-task-definition` file, replace all variables in brackets `<>` with real values
6. Start task on ECS cluster: check the `start.sh` file, replace all variables in brackets `<>` with real values
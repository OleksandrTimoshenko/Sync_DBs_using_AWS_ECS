#!/bin/bash

aws ecs run-task \
    --cluster <YOUR_AWS_CLUSTER_NAME> \
    --launch-type FARGATE \
    --task-definition <YOUR_AWS_CLUSTER_NAME> \
    --network-configuration "awsvpcConfiguration={subnets=[<YOUR_SUBNETS_LIST>],securityGroups=[<YOUR_SECURITY_GROUPS>],assignPublicIp=ENABLED}"

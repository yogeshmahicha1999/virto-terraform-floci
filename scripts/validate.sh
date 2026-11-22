#!/usr/bin/env bash
# Floci me bane resources verify karta hai. Koi secret print nahi karta.
set -uo pipefail
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source floci/env.sh

PASS=0; FAIL=0
check() {  # check "naam" "command"
  if out=$(eval "$2" 2>&1) && [ -n "$out" ] && [ "$out" != "None" ]; then
    echo "PASS  $1"; PASS=$((PASS+1))
  else
    echo "FAIL  $1"; FAIL=$((FAIL+1))
  fi
}

check "Floci reachable (STS)"   "aws sts get-caller-identity --query Account --output text"
check "VPC"                     "aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text"
check "Subnets (4)"             "aws ec2 describe-subnets --query 'Subnets[].SubnetId' --output text"
check "Security groups"         "aws ec2 describe-security-groups --query 'SecurityGroups[].GroupName' --output text | grep virto-floci"
check "S3 frontend bucket"      "aws s3api head-bucket --bucket virto-floci-frontend && echo ok"
check "Secrets Manager secret"  "aws secretsmanager describe-secret --secret-id virto-floci/db-credentials --query Name --output text"
check "ECR repository"          "aws ecr describe-repositories --query 'repositories[].repositoryName' --output text"
check "IAM roles"               "aws iam list-roles --query 'Roles[].RoleName' --output text | grep virto-floci"
check "RDS instance"            "aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier' --output text"
check "EFS file system"         "aws efs describe-file-systems --query 'FileSystems[].FileSystemId' --output text"
check "ALB"                     "aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName' --output text"
check "ECS cluster"             "aws ecs list-clusters --query 'clusterArns[]' --output text"
check "ECS service ACTIVE"      "aws ecs describe-services --cluster virto-floci-cluster --services virto-floci-platform --query 'services[].status' --output text | grep ACTIVE"
check "CloudFront distribution" "aws cloudfront list-distributions --query 'DistributionList.Items[].Id' --output text"
check "SNS topic"               "aws sns list-topics --query 'Topics[].TopicArn' --output text | grep virto-floci"
check "CloudWatch alarms (5)"   "aws cloudwatch describe-alarms --query 'MetricAlarms[].AlarmName' --output text | grep virto-floci"

echo
echo "Result: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

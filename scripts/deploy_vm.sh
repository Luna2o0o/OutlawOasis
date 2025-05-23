#!/bin/bash
REGION="us-east-1"

AMI_ID=$(aws ec2 describe-images \
    --owners "137112412989" \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
              "Name=state,Values=available" \
    --query "Images[*].[ImageId,CreationDate]" \
    --region $REGION --output text | sort -k2 -r | head -n1 | cut -f1)

aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name crimsonkey \
    --security-groups default \
    --user-data file://scripts/setup.sh \
    --region $REGION \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=crimson-bash-vm}]'

aws s3 mb s3://crimson-logs-luna
aws s3 cp logs/crimson_log1.txt s3://crimsion-logs-luna/

aws s3 mb s3://crimson-sensor-logs
aws s3 cp logs/ride_sensor_log.json s3://crimson-sensor-logs/

aws sns create-topic --name ride-alerts
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:<your-account-id>:ride-alerts \
  --protocol email \
  --notification-endpoint litzi.lunacolorado@peopelshores.com

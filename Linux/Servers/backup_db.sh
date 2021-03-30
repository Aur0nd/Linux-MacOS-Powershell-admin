#!/bin/bash
# NOTE: Use Jenkins or hardcode your credentials and CRON it (I personally use it for my esxi & NAS servers at home)
DATE=$(date +%H-%M-%S)
BACKUP=db-$DATE.sql
DB_HOST=$1
DB_PASSWORD=$2
DB_NAME=$3
AWS_SECRET=$4
BUCKET_NAME=$5

mysqldump -u root -h $DB_HOST -p$DB_PASSWORD $DB_NAME > /tmp/$BACKUP && \
export AWS_ACCESS_KEY_ID=$AWS_ACCESS
export  AWS_ACCESS_KEY_ID=$AWS_SECRET && \
aws s3 cp /tmp/$BACKUP s3://$BACKUP/db-$DATE.sql

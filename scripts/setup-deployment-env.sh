#!/usr/bin/env bash

echo "Setting environment variables..."
echo "------------------------------"

ENV_FILE=deployment-env

# Docker image
TARGET_EMAIL_PROCESSOR_IMAGE=modern-java-web/email-processor:1.0.0
TARGET_EMAIL_PROCESSOR_IMAGE_FILE=modern-java-web-email-processor-1.0.0.tar

# Invoke AZD to get the values
azd env get-values > $ENV_FILE

echo "TARGET_EMAIL_PROCESSOR_IMAGE=$TARGET_EMAIL_PROCESSOR_IMAGE" >> $ENV_FILE
echo "TARGET_EMAIL_PROCESSOR_IMAGE_FILE=$TARGET_EMAIL_PROCESSOR_IMAGE_FILE" >> $ENV_FILE

# echo the file that was created
echo "Environment variables set in $ENV_FILE. Make sure to source it before running any other scripts."
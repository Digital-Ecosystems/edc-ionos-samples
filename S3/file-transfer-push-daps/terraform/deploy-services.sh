#!/bin/bash

COMMAND=$1

if [ -z $COMMAND ]; then
    COMMAND="apply"
fi

set -e

source .env

# Check for environment variables
if [ -z `printenv TF_VAR_kubeconfig` ]; then
    echo "Stopping because TF_VAR_kubeconfig is undefined"
    exit 1
fi

if [ -z `printenv KUBECONFIG` ]; then
    echo "Stopping because KUBECONFIG is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_daps_url` ]; then
    echo "Stopping because TF_VAR_daps_url is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_s3_access_key` ]; then
    echo "Stopping because TF_VAR_s3_access_key is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_s3_secret_key` ]; then
    echo "Stopping because TF_VAR_s3_secret_key is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_ionos_token` ]; then
    echo "Stopping because TF_VAR_ionos_token is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_s3_endpoint` ]; then
    echo "Stopping because TF_VAR_s3_endpoint is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_registry_url` ]; then
    echo "Stopping because TF_VAR_registry_url is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_registry_username` ]; then
    echo "Stopping because TF_VAR_registry_username is undefined"
    exit 1
fi

if [ -z `printenv TF_VAR_registry_password` ]; then
    echo "Stopping because TF_VAR_registry_password is undefined"
    exit 1
fi

# Build the project
cd build-project
terraform init
terraform $COMMAND -auto-approve
cd ../

# Build and Push the Docker images
cd build-and-push-docker-images
terraform init
terraform $COMMAND -auto-approve
cd ../

# Create DAPS clients
cd create-daps-clients
terraform init
terraform $COMMAND -auto-approve
cd ../

# Deploy vault
cd vault-deploy
terraform init
terraform $COMMAND -auto-approve
cd ../

# Initialize vault
cd vault-init
terraform init
terraform $COMMAND -auto-approve
cd ../

# Deploy ionos s3
cd ionos-s3-deploy
terraform init
terraform $COMMAND -auto-approve
cd ../

# Configure webhook address
cd configure-ionos-s3-webhook-address
terraform init
terraform $COMMAND -auto-approve
cd ../

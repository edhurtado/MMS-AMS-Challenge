#!/bin/bash
# Initialize gcloud
gcloud init

# Auth with service account
gcloud auth activate-service-account --key-file ./.env/service_account.json

# Defining composer constants
COMPOSER_ENV_NAME="mms_aysm_composer"
COMPOSER_LOCATION="us-west2"
COMPOSER_VERSION="composer-2.6.6-airflow-2.5.3"

# Function to check if the Composer environment exists
check_composer_env_exists() {
    gcloud composer environments describe $COMPOSER_ENV_NAME --location $COMPOSER_LOCATION > /dev/null 2>&1
}

# Check if the Composer environment exists
if check_composer_env_exists; then
    echo "Cloud Composer environment $COMPOSER_ENV_NAME already exists."
else
    echo "Creating Cloud Composer environment $COMPOSER_ENV_NAME..."
    gcloud composer environments create $COMPOSER_ENV_NAME --location $COMPOSER_LOCATION --image-version $COMPOSER_VERSION
fi

# Getting Composer Bucket
BUCKET_URL=$(gcloud composer environments describe $COMPOSER_ENV_NAME --location $COMPOSER_LOCATION --format="get(config.dagGcsPrefix)")
BUCKET_NAME=$(echo $BUCKET_URL | sed 's/^gs:\/\///; s/\/dags\/$//')

# Print Composer details
echo "Bucket name for Cloud Composer is: $BUCKET_NAME"
echo "Composer URL is: $BUCKET_URL"

gsutil cp ../airflow_composer/dags/* gs://$BUCKET_NAME/dags/

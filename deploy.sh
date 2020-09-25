#!/bin/bash

# dev:   ./deploy.sh
# prod:  ./deploy.sh prod
STAGE=${1:-dev}
PROJECT=red-comet-$STAGE
BUILD_DIR=.build
OUTPUT_FILE=$BUILD_DIR/output.yml
TEMPLATE_FILE=template.yml

# Change the suffix on the bucket to something unique!
BUCKET=$PROJECT-deployment-files

# make a build directory to store artifacts
rm -rf $BUILD_DIR
mkdir $BUILD_DIR

# make the deployment bucket in case it doesn't exist
aws s3 mb s3://$BUCKET
aws s3api put-bucket-tagging --bucket $BUCKET --tagging "TagSet=[{Key=environment,Value=$STAGE},{Key=service,Value=deployment}]"

# compile back end
rm -rf ./dist
npm run build

# generate next stage yml file
sam package \
    --template-file $TEMPLATE_FILE \
    --output-template-file $OUTPUT_FILE \
    --s3-bucket $BUCKET                      

# the actual deployment step
sam deploy \
    --template-file $OUTPUT_FILE \
    --stack-name $PROJECT \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameter-overrides Environment=$STAGE

# deploy web-app
# (cd front-end/web-app && npm run generate && npm run deploy --stage=$STAGE)

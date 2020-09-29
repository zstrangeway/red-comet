SHELL=/bin/bash

STAGE ?= dev
PROJECT:=red-comet-${STAGE}
BUILD_DIR:=.build
OUTPUT_FILE:=${BUILD_DIR}/output.yml
TEMPLATE_FILE:=template.yml
BUCKET:=${PROJECT}-deployment-files

abc=deploy

.PHONY: sam-local
sam-local:
	# Run serverless API locally on docker at http://127.0.0.1:5000
	sam local start-api \
		--profile default \
		--region us-east-1 \
		--parameter-overrides 'Environment=dev' \
		--port 5000

.PHONY: deploy
deploy:
	# Return error code 1 if value of STAGE is invalid
	if [ ${STAGE} != "dev" ] && [ ${STAGE} != "prod" ]; then \
		echo ${STAGE} is not a valid input for STAGE.; \
		exit 1; \
	fi;
	
	# make local directory to generated cloudformation templates
	rm -rf ${BUILD_DIR}
	mkdir ${BUILD_DIR}

	# create the deployment bucket in S3 case it doesn't exist
	aws s3 mb s3://${BUCKET}
	aws s3api put-bucket-tagging --bucket ${BUCKET} --tagging "TagSet=[{Key=environment,Value=${STAGE}},{Key=service,Value=deployment}]"

	# compile typescript packages
	rm -rf ./dist
	npm run build

	# generate cloudformation templates
	sam package \
    --template-file ${TEMPLATE_FILE} \
    --output-template-file ${OUTPUT_FILE} \
    --s3-bucket ${BUCKET}

	# the deploy cloudformation and lambdas
	sam deploy \
    --template-file ${OUTPUT_FILE} \
    --stack-name ${PROJECT} \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameter-overrides Environment=${STAGE}

	# deploy web applications to S3
	aws s3 sync ./dist/frontend s3://red-comet-webapp-${STAGE}
	aws s3 sync ./dist/admin s3://red-comet-webadmin-${STAGE}

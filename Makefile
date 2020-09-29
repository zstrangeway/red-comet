SHELL=/bin/bash

# import env variables
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

STAGE ?= dev
APP_NAME:=red-comet
DOMAIN:=redcometcrafts.com
GITHUB_OWNER:=zstrangeway
GITHUB_REPO:=red-comet
GITHUB_BRANCH:=develop # TODO: change to master for prod

# Stack names
PROJECT:=${STAGE}-${APP_NAME}
PIPELINE:=${PROJECT}-pipeline

# BUILD Resource names, paths and buckets
BUILD_DIR:=dist
TEMPLATE_FILE:=template.yml
OUTPUT_FILE:=${BUILD_DIR}/${TEMPLATE_FILE}
DEPLOYMENT_BUCKET:=${PROJECT}-deployment-files
ARTIFACT_BUCKET:=${PROJECT}-artifacts

# Webapp buckets
FRONT_END_BUCKET:=${PROJECT}-frontend
FRONT_END_LOG_BUCKET:=${FRONT_END_BUCKET}-logs
ADMIN_BUCKET:=${PROJECT}-admin
ADMIN_LOG_BUCKET:=${ADMIN_BUCKET}-logs

# URLs
API_DOMAIN:=dev-api.${DOMAIN} # TODO: api.redcometcrafts.com for prod
FRONTEND_DOMAIN:=dev.${DOMAIN} # TODO: redcometcrafts.com for prod
ADMIN_DOMAIN:=dev-admin.${DOMAIN} # TODO: admin.redcometcrafts.com for prod

# Overide values if prod
ifeq (${STAGE}, prod)
		GITHUB_BRANCH:=master
		API_DOMAIN:=api.${DOMAIN}
		FRONTEND_DOMAIN:=${DOMAIN}
		ADMIN_DOMAIN:=admin.${DOMAIN}
endif

.PHONY: sam_local
sam_local:
	# Run serverless API locally on docker at http://127.0.0.1:5000
	sam local start-api \
		--profile default \
		--region us-east-1 \
		--parameter-overrides 'Environment=dev' \
		--port 5000

.PHONY: create_deploy_bucket
create_deploy_bucket:
	# create the deployment bucket in S3 case it doesn't exist
	aws s3 mb s3://${DEPLOYMENT_BUCKET}
	aws s3api put-bucket-tagging \
		--bucket ${DEPLOYMENT_BUCKET} \
		--tagging "TagSet=[{Key=environment,Value=${STAGE}},{Key=service,Value=deployment}]"

.PHONY: build
build:
	# Build application for dev, override STAGE=prod to deploy to prod

	# Return error code 1 if value of STAGE is invalid
	if [ ${STAGE} != "dev" ] && [ ${STAGE} != "prod" ]; then \
		echo ${STAGE} is not a valid input for STAGE.; \
		exit 1; \
	fi;
	
	# make local directory for generated cloudformation templates
	rm -rf ${BUILD_DIR}
	mkdir ${BUILD_DIR}

	# compile typescript packages
	rm -rf ./dist
	npm run build

	# generate cloudformation templates
	sam package \
    --template-file ${TEMPLATE_FILE} \
    --output-template-file ${OUTPUT_FILE} \
    --s3-bucket ${DEPLOYMENT_BUCKET}

.PHONY: deploy
deploy:
	# Deploy cloudformation and lambdas to dev, override STAGE=prod to deploy to prod

	# Return error code 1 if value of STAGE is invalid
	if [ ${STAGE} != "dev" ] && [ ${STAGE} != "prod" ]; then \
		echo ${STAGE} is not a valid input for STAGE.; \
		exit 1; \
	fi;

	make build

	sam deploy \
    --template-file ${OUTPUT_FILE} \
    --stack-name ${PROJECT} \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameter-overrides \
			Environment=${STAGE} \
			HostedZone=${DOMAIN} \
			ApiDomainName=${API_DOMAIN} \
			FrontendDomainName=${FRONTEND_DOMAIN} \
			FrontendRootBucketName=${FRONT_END_BUCKET} \
			FrontendLogBucketName=${FRONT_END_LOG_BUCKET} \
			AdminDomainName=${ADMIN_DOMAIN} \
			AdminRootBucketName=${ADMIN_BUCKET} \
			AdminLogBucketName=${ADMIN_LOG_BUCKET}

	# deploy web applications to S3
	aws s3 sync ./dist/frontend s3://${FRONT_END_BUCKET}
	aws s3 sync ./dist/admin s3://${ADMIN_BUCKET}

.PHONY: teardown
teardown:
	# Teardown dev stack, override STAGE=prod to teardown prod
	echo "not implemented"
	# TODO
	# Create snapshots
	# Empty all S3 buckets
	# Delete CloudFormation stack
	# Delete deployment bucket

.PHONY: deploy-pipeline
deploy_pipeline:
	# Create CodePipeline for dev, override STAGE=prod to create for prod
	aws s3 mb s3://${ARTIFACT_BUCKET}

	aws cloudformation deploy \
		--template-file templates/cicd.template.yml \
		--capabilities CAPABILITY_NAMED_IAM \
		--stack-name ${PIPELINE} \
		--parameter-overrides \
			Environment=${STAGE} \
			TargetStack=${PROJECT} \
			GitHubOAuthToken=${GITHUB_TOKEN} \
			GitHubOwner=${GITHUB_OWNER} \
			GitHubRepo=${GITHUB_REPO} \
			GitHubBranch=${GITHUB_BRANCH} \
			DeploymentBucket=${DEPLOYMENT_BUCKET} \
			BuildArtifactsBucket=${ARTIFACT_BUCKET} \
			HostedZone=${DOMAIN} \
			ApiDomainName=${API_DOMAIN} \
			FrontendDomainName=${FRONTEND_DOMAIN} \
			FrontendRootBucketName=${FRONT_END_BUCKET} \
			FrontendLogBucketName=${FRONT_END_LOG_BUCKET} \
			AdminDomainName=${ADMIN_DOMAIN} \
			AdminRootBucketName=${ADMIN_BUCKET} \
			AdminLogBucketName=${ADMIN_LOG_BUCKET}

.PHONY: teardown_pipline
teardown_pipline:
	# Teardown CI/CD pipline
	echo "not implemented"
	# TODO

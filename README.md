# red-comet
Website for Red Comet Creations.

## Tech Stack
- Next.js
- Node.js
- Typescript
- Lerna
- ESLint
- AWS
  - Amplify
  - API Gateway
  - Certificate Manager
  - CloudFront
  - Cognito
  - DynamoDB
  - DynamoDB Streams
  - Lambda
  - Route53
  - S3
  - SAM/CloudFormation
  - SES

## Prerequisites
- [node](https://nodejs.org/en/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- [AWS Amplify CLI](https://docs.amplify.aws/cli/start/install)
- [docker](https://docs.docker.com/get-docker/)

## Getting started
- Set up domain in Route 53
- Update domains in `template.yml` to have desired domain and bucket names
- Update `Makefile` with appropriate names for your aws S3 buckets
- `npm i` in `root` dir, `packages/frontend` and `packages/admin`
- `npm run dev` - starts local servers
  - frontend - localhost:3000
  - admin - localhost:4000
  - api - localhost:5000
- `npm run deploy` deploy to devlopment environment
- `npm run deploy:prod` deploy to production

## Backlog
- Create teardown script
- CI/CD
- API
  - authentication
  - quote service
  - gallery service
- Frontend
  - Home
  - About
  - Services
    - Longarm Quotes
  - Gallery
  - Contact
- Admin
  - Users
  - Contacts
  - Quotes
  - Gallery

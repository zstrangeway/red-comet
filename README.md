# red-comet
Website for Red Comet Creations.

## Tech Stack
- Node.js
- React
- Next.js
- Typescript
- Lerna
- ESLint
- AWS
  - Amplify
  - API Gateway
  - Certificate Manager
  - CloudFront
  - CodeBuild
  - CodePipeline
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

## CICD
- Be sure to edit the pipeline and click connect to GitHub to authorize AWS CodeSuite as an oAuth app in your repo

## Backlog
- House keeping
  - Better "Get Started" sections in README
  - Add lifecycle hooks to S3 buckets to remove old files
  - Add better logging and alarms
  - Clean up CloudFormation resource permissions
  - Split out serverless api cfn into its own template file.
  - local AWS services?
    - DynamoDB
    - SES
- build scripts
  - Create teardown scripts
- CI/CD
  - Move GitHub token to AWS Secrets Manager
  - Add cache busting/cdn invalidations
- API
  - authentication
  - quote service
  - gallery service
- Frontend
  - SEO
    - Optimize scores on:
      - Google Pagespeed
      - Google Lightspeed
    - Static content caching
    - image optimization
    - Automate sitemap, robots.txt & human.txt generation?
      - Possible solutions: https://leerob.io/blog/nextjs-sitemap-robots
    - Add Google Analytics
      - Analyze performance
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

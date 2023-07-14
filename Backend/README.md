# AWS Cloud Resume Challenge Backend
- Terraform Configuration and Testing requirements for AWS Cloud Resume Challenge Backend
- Automates provisioning of DynamoDB, Lambda, and API Gateway and related permissions for the Visitor Count feature. 
- Terraform uses a remote S3 Backend with DynamoDB for state locking. Partial Backend configuration used in CI/CD. 
- DynamoDB Visitor Count table Lambda function and unit test included
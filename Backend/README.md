# AWS Cloud Resume Challenge Terraform Backend
- Terraform Configuration for backend portion of AWS Cloud Resume Challenge. 
- Automates the creation of DynamoDB, Lambda, and API Gateway and related permissions.
- Uses a remote S3 Backend with DynamoDB for state locking 
- Code for lambda function that retrieves and update dynamoDB table items also included. 
- unit test for lambda function using moto included
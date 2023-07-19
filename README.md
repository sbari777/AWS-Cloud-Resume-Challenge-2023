## <div align="center"> AWS CLOUD RESUME CHALLENGE <div>

![Website Architecture](/img/Cloud%20Resume%20Architecture.jpg)

 [Forrest Brazeal's](https://forrestbrazeal.com/#about) [Cloud Resume Challenge](https://cloudresumechallenge.dev/)  is a series of exercises designed to enhance cloud technology skills through building a Portfolio/Resume site. 

 This code repository showcases my [solution to the challenge, hosted on AWS](http://saifbari.com). Below, I've detailed the project requirements, along with my personal notes.

 ## <div align="center"> REQUIREMENTS <div>

### Certifications 
- Obtained [AWS Solutions Architect Associate](https://www.credly.com/badges/3e2a0155-7c5e-4243-acd3-34c4e6c1c195/public_url), [AWS SysOps Administrator Associate](https://www.credly.com/badges/db4955c2-3870-47ba-803c-fb1a026b9851/public_url), and [HashiCorp Certified: Terraform Associate](https://www.credly.com/badges/d314e92f-f359-4961-92b3-efa1ad8ca38d/public_url) certification

### HTML
- Designed using HUGO static site generator
- Used [chringel-hugo-theme](https://github.com/chringel21/chringel-hugo-theme) as a template
- Uses markdown for the various pages on the site. 
- Created and/or customized layouts, partials, and shortcodes.

### CSS
- Template uses Tailwind CSS.  
    - Modified CSS to force Dark mode, alter color scheme, and font stylings. 
- Changed media queries to prefer dark mode and changed relative inline elements to enforce dark mode.        

### Static Website and HTTPS
- Hosted in a private S3 bucket without static website hosting.
- Visitors access the site via a Cloudfront Distribution configured with OAC, and not directly from the S3 origin. 
    - OAC only functions with S3 buckets, and S3 buckets don't auto-serve index.html for root/subdirectories. Cloudfront's root object feature is exclusive to the root and excludes subdirectories. 
        - To make subdirectories accessible, append 'index.html' to URIs. [This requires a Cloudfront Function triggered by viewer request to be associated with the distribution](https://github.com/aws-samples/amazon-cloudfront-functions/blob/main/url-rewrite-single-page-apps/index.js)
- HTTPS is enabled through an SSL certificate from Amazon Certificate Manager.

### DNS
- Registered domain in Route53
- A record routes traffic to cloudfront distribution
- Enabled DNSSEC

### Javascript
- The site uses [Javascript](https://github.com/sbari777/AWS-Cloud-Resume-Challenge-2023/blob/main/Frontend/static/js/visitor-counter.js) to update and retrieve visitor count via an API url. 
    - It parses the API's JSON response, extracts the visitor count, and then updates the visitor counter HTML element with the derived count. 

### Database 
- Visitor Count is stored in a DynamoDB table.
- A separate DynamoDB table holds the Terraform state lock.

### API 
- The front-end interacts with DynamoDB through a combination of API Gateway and Lambda.
- The Lambda function, invoked by the API Gateway, facilitates reading and writing to the DynamoDB table.
- API Gateway is configured with a GET method for visitor count retrieval and an OPTIONS method with MOCK integration to support CORS.

### Python & Testing
- [Visitor Count Lambda function](https://github.com/sbari777/AWS-Cloud-Resume-Challenge-2023/blob/main/Backend/Tests/lambda_function.py) and its [unit test](https://github.com/sbari777/AWS-Cloud-Resume-Challenge-2023/blob/main/Backend/Tests/visitor-counter-test.py) are written in Python. 
- The lambda function uses the Boto3 library for DynamoDB interaction, while the unit test uses the moto library to mock DynamoDB and assert the validity of the Lambda function code. 

### Infrastructure as Code (IaC)
- The backend infrastructure for the visitor counter, including API Gateway, Lambda, DynamoDB, and their IAM configurations, is managed and deployed using Terraform.
    - Terraform is configured with a remote S3 backend and DynamoDB for state locking. 
- The [configuration](https://github.com/sbari777/AWS-Cloud-Resume-Challenge-2023/blob/main/Backend/main.tf) uses a mix of modules and resource blocks to establish infrastructure.

### Source Control & CI/CD (Back end and Front end)
![Github Actions](/img/GithubActions.jpg)
- GitHub serves as the version control system, with GitHub Actions functioning as the CI/CD pipeline.
- [The GitHub Actions workflow](https://github.com/sbari777/AWS-Cloud-Resume-Challenge-2023/blob/main/.github/workflows/Deployment%20Pipeline.yml) detects changes in the frontend or backend of the repository and accordingly deploy the backend infrastructure or frontend content.
    - Unit testing is automated. If successful, it pushes code to the backend code bucket, from which Terraform retrieves code for the Lambda function.
    - If the unit test passes and there are changes in the backend directory, the Terraform workflow is triggered. A partial backend config initializes the remote backend for Terraform. 
    - If frontend changes occur, HUGO builds the site from the Frontend subdirectory, deploys it to the Front End S3 bucket, and invalidates the Cloudfront cache.


### Blog Post 
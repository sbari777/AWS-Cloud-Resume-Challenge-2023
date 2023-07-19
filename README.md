## <div align="center"> AWS CLOUD RESUME CHALLENGE <div>

![Website Architecture](/img/Cloud%20Resume%20Architecture.jpg)

 [Forrest Brazeal's](https://forrestbrazeal.com/#about) [Cloud Resume Challenge](https://cloudresumechallenge.dev/)  is a series of exercises designed to enhance cloud technology skills through building a Portfolio/Resume site. 

 This code repository showcases my [solution to the challenge, hosted on AWS](http://saifbari.com). Below, I've detailed the project requirements, along with my personal notes.

 ## <div align="center"> REQUIREMENTS <div>

### Certifications 
- Obtained [AWS Solutions Architect Associate](https://www.credly.com/badges/3e2a0155-7c5e-4243-acd3-34c4e6c1c195/public_url) and [AWS SysOps Administrator Associate](https://www.credly.com/badges/db4955c2-3870-47ba-803c-fb1a026b9851/public_url) certification

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

### Javascript

### Database 

### API 

### Python 

### Tests 

### Infrastructure as Code (IaC) 

### Source Control 

### CI/CD (Back end) 

### CI/CD (Front End) 

### Blog Post 
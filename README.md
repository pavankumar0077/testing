# Terraform ECS Infrastructure

This repository contains Terraform code to deploy an Amazon ECS (Elastic Container Service) infrastructure following best practices for code modularity and state management.

## Project Structure

```
.
├── README.md                 # Project documentation
├── main.tf                   # Main Terraform configuration
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── providers.tf              # Provider configurations
├── backend.tf                # State management configuration
├── environments/             # Environment-specific configurations
│   ├── dev/                  # Development environment
│   │   ├── terraform.tfvars  # Dev environment variables
│   │   └── backend.tfvars    # Dev backend configuration
│   └── prod/                 # Production environment
│       ├── terraform.tfvars  # Prod environment variables
│       └── backend.tfvars    # Prod backend configuration
└── modules/                  # Reusable Terraform modules
    ├── networking/           # VPC and networking components
    ├── ecs/                  # ECS cluster, tasks, and services
    ├── iam/                  # IAM roles and policies
    └── alb/                  # Application Load Balancer
```

## Features

- **Modular Design**: Separate modules for networking, ECS, IAM, and load balancing
- **Remote State Management**: Configured for S3 backend with DynamoDB locking
- **Environment Support**: Separate configurations for development and production
- **Security Best Practices**: Least privilege IAM policies and secure networking

## Usage

### Prerequisites

- Terraform v1.0.0+
- AWS CLI configured with appropriate credentials
- S3 bucket and DynamoDB table for remote state (optional)

### Deployment

1. Initialize Terraform with the appropriate backend:
   ```
   terraform init -backend-config=environments/dev/backend.tfvars
   ```

2. Apply the configuration:
   ```
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

3. To switch to production:
   ```
   terraform init -reconfigure -backend-config=environments/prod/backend.tfvars
   terraform apply -var-file=environments/prod/terraform.tfvars
   ```

## State Management

This project uses Terraform remote state stored in S3 with DynamoDB for state locking. This approach:
- Enables team collaboration
- Prevents state corruption from concurrent modifications
- Keeps sensitive information off local disks
- Provides state versioning

## Troubleshooting

### Backend Configuration Issues

If you encounter errors during `terraform init` related to the S3 backend, ensure that:

1. The S3 bucket specified in your backend.tfvars file exists
2. You have the necessary permissions to access the bucket
3. The DynamoDB table for state locking exists and is accessible

For local development or testing without an S3 backend, you can temporarily modify the backend.tf file to use a local backend:

```hcl
terraform {
  backend "local" {}
}
```

### Variable and Locals Issues

The main.tf file uses a locals block to define common values and tags used throughout the configuration. All variables referenced in the locals block are defined in variables.tf. If you encounter errors related to undefined variables:

1. Ensure all variables used in main.tf are properly defined in variables.tf
2. Check that you're providing values for all required variables either in terraform.tfvars files or via command line
3. Verify that the variable types match their usage (e.g., string vs. map vs. list)

### AWS Provider Authentication

If you encounter AWS authentication errors:

1. Ensure your AWS credentials are properly configured
2. Verify that the IAM user or role has the necessary permissions
3. For testing environments, you can modify the providers.tf file to skip credential validation:

```hcl
provider "aws" {
  region = var.aws_region
  
  # For testing only - do not use in production
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
```

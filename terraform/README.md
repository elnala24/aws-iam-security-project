# Terraform Implementation

This directory contains the Terraform implementation of the StartupCo IAM security solution. It creates the same infrastructure as the CloudFormation template but uses Terraform's HCL syntax.

## What Gets Created

- **4 IAM Groups:** developers-group, operations-group, finance-group, analysts-group
- **4 Custom IAM Policies:** One for each group with appropriate permissions
- **MFA Enforcement Policy:** Attached to all groups
- **4 Sample IAM Users:** One per group as examples
- **Account Password Policy:** Strong password requirements

## Prerequisites

1. **Install Terraform**
```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Verify installation
   terraform version
```

2. **AWS CLI Configured**
```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Default region: us-east-1
   # Default output format: json
```

3. **Get Your AWS Account ID**
```bash
   aws sts get-caller-identity --query Account --output text
```

## Setup

1. **Navigate to the terraform directory**
```bash
   cd terraform
```

2. **Create your variables file**
```bash
   cp terraform.tfvars.example terraform.tfvars
```

3. **Edit terraform.tfvars with your values**
```bash
   nano terraform.tfvars
```
   
   Replace `123456789012` with your actual AWS Account ID.

4. **Initialize Terraform**
```bash
   terraform init
```
   
   This downloads the AWS provider plugin.

## Deployment

### Preview Changes
```bash
terraform plan
```

This shows what Terraform will create without actually creating it. Review carefully!

### Apply Changes
```bash
terraform apply
```

Type `yes` when prompted. Terraform will:
- Create all IAM groups
- Create all IAM policies
- Attach policies to groups
- Create sample users
- Set password policy

### View Outputs
After deployment, Terraform displays outputs like:
```
developers_group_arn = "arn:aws:iam::123456789012:group/developers-group"
created_users = [
  "dev-john-smith",
  "ops-jane-doe",
  "finance-manager",
  "analyst-alice-wong"
]
```

## File Structure
```
terraform/
├── main.tf                      # Main resources (groups, users, policies)
├── variables.tf                 # Input variable definitions
├── outputs.tf                   # Output definitions
├── provider.tf                  # AWS provider configuration
├── terraform.tfvars.example     # Example variables file
├── terraform.tfvars             # Your actual values (git-ignored)
└── README.md                    # This file
```

## Key Terraform Concepts

### Resources
Resources are infrastructure components you want to create:
```hcl
resource "aws_iam_group" "developers" {
  name = "developers-group"
}
```

### Variables
Variables make your code reusable:
```hcl
variable "aws_region" {
  default = "us-east-1"
}
```

Use variables with: `var.aws_region`

### Outputs
Outputs display information after deployment:
```hcl
output "group_name" {
  value = aws_iam_group.developers.name
}
```

### Data Sources
Reference resources from variables:
```hcl
Resource = "arn:aws:iam::${var.aws_account_id}:user/*"
```

## Useful Commands
```bash
# Initialize (run once)
terraform init

# Format code
terraform fmt

# Validate syntax
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy everything (careful!)
terraform destroy

# Show current state
terraform show

# List all resources
terraform state list
```

## Differences from CloudFormation

| Feature | CloudFormation | Terraform |
|---------|---------------|-----------|
| Language | YAML/JSON | HCL |
| State | AWS manages | Local/Remote file |
| Provider | AWS only | Multi-cloud |
| Modularity | Nested stacks | Modules |
| Drift detection | Built-in | Via plan |

## Common Issues

### Issue: "Error: No valid credential sources found"
**Solution:** Run `aws configure` and enter your credentials.

### Issue: "Error acquiring the state lock"
**Solution:** Another terraform process is running. Wait or delete `.terraform.tfstate.lock.info`

### Issue: "Error: variable 'aws_account_id' not set"
**Solution:** Create `terraform.tfvars` from the example file and add your account ID.

## Adding More Users

To add additional users, copy this block in `main.tf`:
```hcl
resource "aws_iam_user" "developer_2" {
  name = "dev-another-user"
  
  tags = {
    Team        = "Development"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "developer_2_groups" {
  user = aws_iam_user.developer_2.name
  groups = [
    aws_iam_group.developers.name
  ]
}
```

Then run `terraform apply`.

## Cleanup

To remove all created resources:
```bash
terraform destroy
```

Type `yes` when prompted. This will delete:
- All IAM users
- All IAM groups
- All IAM policies
- Password policy

**Note:** This cannot be undone!

## Next Steps

- Compare this with the CloudFormation implementation
- Try modifying policies and running `terraform plan`
- Create additional users for all team members
- Learn about Terraform modules for better organization

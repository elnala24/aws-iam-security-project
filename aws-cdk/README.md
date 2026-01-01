# AWS CDK Implementation (Python)

This directory contains the AWS CDK (Cloud Development Kit) implementation of the StartupCo IAM security solution. CDK allows you to define cloud infrastructure using Python code, which then generates CloudFormation templates.

## What Gets Created

- **4 IAM Groups:** developers-group, operations-group, finance-group, analysts-group
- **4 Custom IAM Policies:** One for each group with appropriate permissions
- **MFA Enforcement Policy:** Attached to all groups
- **4 Sample IAM Users:** One per group as examples
- **Account Password Policy:** Must be set via CLI (see below)

## Why CDK?

Unlike CloudFormation (YAML/JSON) and Terraform (HCL), CDK lets you use a real programming language (Python, TypeScript, Java, etc.). This means:
- **Real programming constructs:** loops, conditionals, functions
- **Type safety:** Catch errors before deployment
- **IDE support:** Auto-complete and inline documentation
- **Reusable components:** Create your own constructs
- **Less verbose:** CDK abstracts away boilerplate

## Prerequisites

### 1. Install Node.js and AWS CDK CLI

CDK CLI requires Node.js even though we're using Python:

```bash
# macOS
brew install node
npm install -g aws-cdk

# Verify installation
cdk --version
```

### 2. Install Python 3.7+

```bash
# Check Python version
python3 --version

# Should be 3.7 or higher
```

### 3. AWS CLI Configured

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key  
# Default region: us-east-1
# Default output format: json
```

### 4. Bootstrap CDK (First Time Only)

CDK needs to create some infrastructure in your AWS account:

```bash
cd aws-cdk
cdk bootstrap
```

This creates an S3 bucket and other resources for CDK deployments.

## Setup

### 1. Create Python Virtual Environment

```bash
cd aws-cdk

# Create virtual environment
python3 -m venv .venv

# Activate it
# macOS/Linux:
source .venv/bin/activate

# Windows:
.venv\Scripts\activate.bat
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Verify Setup

```bash
cdk ls
```

You should see: `StartupCoIamStack`

## Deployment

### Preview Changes (Synth)

```bash
cdk synth
```

This generates the CloudFormation template. You'll see YAML output in your terminal.

### Preview Changes (Diff)

```bash
cdk diff
```

This shows what will change in your AWS account.

### Deploy to AWS

```bash
cdk deploy
```

Type `y` when prompted. CDK will:
1. Generate CloudFormation template
2. Upload assets to S3
3. Create/update the CloudFormation stack
4. Display outputs when complete

### View Outputs

After deployment, you'll see outputs like:
```
StartupCoIamStack.DevelopersGroupArn = arn:aws:iam::123456789012:group/developers-group
StartupCoIamStack.OperationsGroupArn = arn:aws:iam::123456789012:group/operations-group
...
```

### Set Password Policy

CDK doesn't have a native construct for password policy. Set it via CLI:

```bash
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --max-password-age 90 \
  --password-reuse-prevention 5 \
  --allow-users-to-change-password
```

## File Structure

```
aws-cdk/
├── app.py                    # CDK app entry point
├── cdk_stack.py             # Stack with all IAM resources
├── requirements.txt         # Python dependencies
├── cdk.json                 # CDK configuration
├── .gitignore              # Git ignore for CDK
└── README.md               # This file
```

## Key CDK Concepts

### Constructs

Everything in CDK is a "construct" - a reusable cloud component:

```python
# Create an IAM group (L2 construct - high-level)
group = iam.Group(self, "MyGroup", group_name="my-group")
```

### Stacks

Stacks are units of deployment (maps to CloudFormation stack):

```python
class MyStack(Stack):
    def __init__(self, scope, id, **kwargs):
        super().__init__(scope, id, **kwargs)
        # Resources go here
```

### Apps

Apps contain one or more stacks:

```python
app = cdk.App()
MyStack(app, "MyStack")
app.synth()
```

### Levels of Constructs

- **L1 (CFN Resources):** Direct CloudFormation - prefix `Cfn`
- **L2 (Curated):** Higher-level with sensible defaults - most common
- **L3 (Patterns):** Complete solutions combining multiple resources

## Useful Commands

```bash
# List all stacks
cdk ls

# Generate CloudFormation template
cdk synth

# Show differences from deployed stack
cdk diff

# Deploy stack
cdk deploy

# Destroy stack
cdk destroy

# View CDK documentation
cdk docs
```

## Comparison with Other IaC Tools

| Feature | CloudFormation | Terraform | CDK |
|---------|---------------|-----------|-----|
| Language | YAML/JSON | HCL | Python/TypeScript/Java |
| Type Safety | No | Partial | Yes |
| IDE Support | Limited | Good | Excellent |
| Learning Curve | Easy | Medium | Medium-Hard |
| Cloud Support | AWS only | Multi-cloud | AWS (+ experimental) |
| State Management | AWS managed | File-based | CloudFormation |

## CDK vs CloudFormation

CDK generates CloudFormation behind the scenes, but gives you:
- **Less code:** CDK's abstractions reduce boilerplate by 50-70%
- **Smarter defaults:** Security best practices built-in
- **Programming power:** Use loops, functions, conditionals
- **Type safety:** Catch errors at development time

Example - Creating 10 users:

**CloudFormation:** ~200 lines of YAML (repetitive)

**CDK:** 
```python
for i in range(10):
    iam.User(self, f"User{i}", user_name=f"user-{i}")
```

## Common Issues

### Issue: "CDK command not found"
**Solution:** Install CDK CLI: `npm install -g aws-cdk`

### Issue: "This stack uses assets, so the toolkit stack must be deployed"
**Solution:** Run `cdk bootstrap` once per AWS account/region

### Issue: "Unable to resolve AWS account"
**Solution:** Run `aws configure` and ensure credentials are set

### Issue: "No module named 'aws_cdk'"
**Solution:** Activate virtual environment and run `pip install -r requirements.txt`

## Adding More Users

To add more users, edit `cdk_stack.py`:

```python
# Add this in the IAM USERS section
developer_user_2 = iam.User(
    self, "DeveloperUser2",
    user_name="dev-another-user",
    groups=[developers_group]
)
```

Then run `cdk deploy`.

## Cleanup

To remove all resources:

```bash
cdk destroy
```

Type `y` when prompted. This deletes:
- All IAM users
- All IAM groups
- All IAM policies
- CloudFormation stack

**Note:** Password policy must be removed separately via CLI.

## Next Steps

- Learn about [CDK Patterns](https://cdkpatterns.com/)
- Explore [Construct Hub](https://constructs.dev/) for reusable constructs
- Try creating your own custom constructs
- Compare the generated CloudFormation with your manual template

## Resources

- [CDK Python Documentation](https://docs.aws.amazon.com/cdk/api/v2/python/)
- [CDK Workshop](https://cdkworkshop.com/)
- [Best Practices](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html)

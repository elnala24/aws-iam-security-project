# ==========================================
# IAM GROUPS
# ==========================================

resource "aws_iam_group" "developers" {
  name = "developers-group"
  path = "/"
}

resource "aws_iam_group" "operations" {
  name = "operations-group"
  path = "/"
}

resource "aws_iam_group" "finance" {
  name = "finance-group"
  path = "/"
}

resource "aws_iam_group" "analysts" {
  name = "analysts-group"
  path = "/"
}

# ==========================================
# IAM POLICIES - Developers
# ==========================================

resource "aws_iam_policy" "developers_policy" {
  name        = "DevelopersPolicy"
  description = "Policy for developers - EC2, S3, CloudWatch access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2FullAccess"
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ApplicationAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.app_bucket_prefix}-*",
          "arn:aws:s3:::${var.app_bucket_prefix}-*/*"
        ]
      },
      {
        Sid    = "CloudWatchLogsReadOnly"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "developers_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developers_policy.arn
}

# ==========================================
# IAM POLICIES - Operations
# ==========================================

resource "aws_iam_policy" "operations_policy" {
  name        = "OperationsPolicy"
  description = "Policy for operations team - Full infrastructure access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2FullAccess"
        Effect   = "Allow"
        Action   = ["ec2:*"]
        Resource = "*"
      },
      {
        Sid      = "RDSFullAccess"
        Effect   = "Allow"
        Action   = ["rds:*"]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchFullAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "SystemsManagerAccess"
        Effect = "Allow"
        Action = [
          "ssm:*",
          "ssmmessages:*",
          "ec2messages:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "VPCAccess"
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      {
        Sid      = "S3FullAccess"
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "operations_attach" {
  group      = aws_iam_group.operations.name
  policy_arn = aws_iam_policy.operations_policy.arn
}

# ==========================================
# IAM POLICIES - Finance
# ==========================================

resource "aws_iam_policy" "finance_policy" {
  name        = "FinancePolicy"
  description = "Policy for finance team - Cost management and read-only access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BillingAccess"
        Effect = "Allow"
        Action = [
          "ce:*",
          "budgets:*",
          "cur:*",
          "aws-portal:ViewBilling",
          "aws-portal:ViewUsage",
          "pricing:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ReadOnlyResourceAccess"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "rds:Describe*",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "finance_attach" {
  group      = aws_iam_group.finance.name
  policy_arn = aws_iam_policy.finance_policy.arn
}

# ==========================================
# IAM POLICIES - Analysts
# ==========================================

resource "aws_iam_policy" "analysts_policy" {
  name        = "AnalystsPolicy"
  description = "Policy for data analysts - Read-only S3 and RDS access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadOnlyAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_bucket_prefix}-*",
          "arn:aws:s3:::${var.data_bucket_prefix}-*/*"
        ]
      },
      {
        Sid    = "RDSReadOnlyAccess"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchReadOnly"
        Effect = "Allow"
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "analysts_attach" {
  group      = aws_iam_group.analysts.name
  policy_arn = aws_iam_policy.analysts_policy.arn
}

# ==========================================
# MFA ENFORCEMENT POLICY
# ==========================================

resource "aws_iam_policy" "mfa_enforcement" {
  name        = "EnforceMFAPolicy"
  description = "Requires MFA for all AWS actions except IAM/STS for MFA setup"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:mfa/$${aws:username}",
          "arn:aws:iam::${var.aws_account_id}:user/$${aws:username}"
        ]
      },
      {
        Sid    = "AllowChangeOwnPassword"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy"
        ]
        Resource = "*"
      },
      {
        Sid       = "DenyAllExceptListedIfNoMFA"
        Effect    = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Attach MFA policy to all groups
resource "aws_iam_group_policy_attachment" "developers_mfa" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.mfa_enforcement.arn
}

resource "aws_iam_group_policy_attachment" "operations_mfa" {
  group      = aws_iam_group.operations.name
  policy_arn = aws_iam_policy.mfa_enforcement.arn
}

resource "aws_iam_group_policy_attachment" "finance_mfa" {
  group      = aws_iam_group.finance.name
  policy_arn = aws_iam_policy.mfa_enforcement.arn
}

resource "aws_iam_group_policy_attachment" "analysts_mfa" {
  group      = aws_iam_group.analysts.name
  policy_arn = aws_iam_policy.mfa_enforcement.arn
}

# ==========================================
# IAM USERS (Examples)
# ==========================================

resource "aws_iam_user" "developer_1" {
  name = "dev-john-smith"
  path = "/"
  
  tags = {
    Team        = "Development"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "developer_1_groups" {
  user = aws_iam_user.developer_1.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user" "operations_1" {
  name = "ops-jane-doe"
  path = "/"
  
  tags = {
    Team        = "Operations"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "operations_1_groups" {
  user = aws_iam_user.operations_1.name
  groups = [
    aws_iam_group.operations.name
  ]
}

resource "aws_iam_user" "finance_1" {
  name = "finance-manager"
  path = "/"
  
  tags = {
    Team        = "Finance"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "finance_1_groups" {
  user = aws_iam_user.finance_1.name
  groups = [
    aws_iam_group.finance.name
  ]
}

resource "aws_iam_user" "analyst_1" {
  name = "analyst-alice-wong"
  path = "/"
  
  tags = {
    Team        = "DataAnalytics"
    Environment = "Production"
  }
}

resource "aws_iam_user_group_membership" "analyst_1_groups" {
  user = aws_iam_user.analyst_1.name
  groups = [
    aws_iam_group.analysts.name
  ]
}

# ==========================================
# ACCOUNT PASSWORD POLICY
# ==========================================

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}

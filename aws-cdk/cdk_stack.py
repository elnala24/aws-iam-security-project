from aws_cdk import (
    Stack,
    aws_iam as iam,
    CfnOutput,
    Fn
)
from constructs import Construct

class StartupCoIamStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # ==========================================
        # IAM GROUPS
        # ==========================================
        
        developers_group = iam.Group(
            self, "DevelopersGroup",
            group_name="developers-group"
        )
        
        operations_group = iam.Group(
            self, "OperationsGroup",
            group_name="operations-group"
        )
        
        finance_group = iam.Group(
            self, "FinanceGroup",
            group_name="finance-group"
        )
        
        analysts_group = iam.Group(
            self, "AnalystsGroup",
            group_name="analysts-group"
        )

        # ==========================================
        # IAM POLICIES - Developers
        # ==========================================
        
        developers_policy = iam.ManagedPolicy(
            self, "DevelopersPolicy",
            managed_policy_name="DevelopersPolicy",
            description="Policy for developers - EC2, S3, CloudWatch access",
            statements=[
                # EC2 Full Access
                iam.PolicyStatement(
                    sid="EC2FullAccess",
                    effect=iam.Effect.ALLOW,
                    actions=["ec2:*"],
                    resources=["*"]
                ),
                # S3 Access for application files
                iam.PolicyStatement(
                    sid="S3ApplicationAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "s3:ListBucket",
                        "s3:GetObject",
                        "s3:PutObject",
                        "s3:DeleteObject"
                    ],
                    resources=[
                        "arn:aws:s3:::startupo-app-*",
                        "arn:aws:s3:::startupo-app-*/*",
                        "arn:aws:s3:::startupo-dev-*",
                        "arn:aws:s3:::startupo-dev-*/*"
                    ]
                ),
                # CloudWatch Logs - Read Only
                iam.PolicyStatement(
                    sid="CloudWatchLogsReadOnly",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "logs:DescribeLogGroups",
                        "logs:DescribeLogStreams",
                        "logs:GetLogEvents",
                        "logs:FilterLogEvents",
                        "cloudwatch:GetMetricData",
                        "cloudwatch:GetMetricStatistics",
                        "cloudwatch:ListMetrics"
                    ],
                    resources=["*"]
                )
            ]
        )
        
        developers_group.add_managed_policy(developers_policy)

        # ==========================================
        # IAM POLICIES - Operations
        # ==========================================
        
        operations_policy = iam.ManagedPolicy(
            self, "OperationsPolicy",
            managed_policy_name="OperationsPolicy",
            description="Policy for operations team - Full infrastructure access",
            statements=[
                # Full EC2 Access
                iam.PolicyStatement(
                    sid="EC2FullAccess",
                    effect=iam.Effect.ALLOW,
                    actions=["ec2:*"],
                    resources=["*"]
                ),
                # Full RDS Access
                iam.PolicyStatement(
                    sid="RDSFullAccess",
                    effect=iam.Effect.ALLOW,
                    actions=["rds:*"],
                    resources=["*"]
                ),
                # Full CloudWatch Access
                iam.PolicyStatement(
                    sid="CloudWatchFullAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "cloudwatch:*",
                        "logs:*"
                    ],
                    resources=["*"]
                ),
                # Systems Manager Access
                iam.PolicyStatement(
                    sid="SystemsManagerAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "ssm:*",
                        "ssmmessages:*",
                        "ec2messages:*"
                    ],
                    resources=["*"]
                ),
                # VPC and Networking
                iam.PolicyStatement(
                    sid="VPCAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "ec2:DescribeVpcs",
                        "ec2:DescribeSubnets",
                        "ec2:DescribeSecurityGroups",
                        "ec2:DescribeNetworkInterfaces",
                        "elasticloadbalancing:*"
                    ],
                    resources=["*"]
                ),
                # S3 Full Access
                iam.PolicyStatement(
                    sid="S3FullAccess",
                    effect=iam.Effect.ALLOW,
                    actions=["s3:*"],
                    resources=["*"]
                )
            ]
        )
        
        operations_group.add_managed_policy(operations_policy)

        # ==========================================
        # IAM POLICIES - Finance
        # ==========================================
        
        finance_policy = iam.ManagedPolicy(
            self, "FinancePolicy",
            managed_policy_name="FinancePolicy",
            description="Policy for finance team - Cost management and read-only access",
            statements=[
                # Billing and Cost Management
                iam.PolicyStatement(
                    sid="BillingAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "ce:*",
                        "budgets:*",
                        "cur:*",
                        "aws-portal:ViewBilling",
                        "aws-portal:ViewUsage",
                        "pricing:*"
                    ],
                    resources=["*"]
                ),
                # Read-only access to resources for cost analysis
                iam.PolicyStatement(
                    sid="ReadOnlyResourceAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "ec2:Describe*",
                        "rds:Describe*",
                        "s3:ListAllMyBuckets",
                        "s3:GetBucketLocation",
                        "cloudwatch:Describe*",
                        "cloudwatch:Get*",
                        "cloudwatch:List*"
                    ],
                    resources=["*"]
                )
            ]
        )
        
        finance_group.add_managed_policy(finance_policy)

        # ==========================================
        # IAM POLICIES - Analysts
        # ==========================================
        
        analysts_policy = iam.ManagedPolicy(
            self, "AnalystsPolicy",
            managed_policy_name="AnalystsPolicy",
            description="Policy for data analysts - Read-only S3 and RDS access",
            statements=[
                # S3 Read-Only Access
                iam.PolicyStatement(
                    sid="S3ReadOnlyAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "s3:ListBucket",
                        "s3:GetObject",
                        "s3:GetBucketLocation"
                    ],
                    resources=[
                        "arn:aws:s3:::startupo-user-data",
                        "arn:aws:s3:::startupo-user-data/*",
                        "arn:aws:s3:::startupo-analytics-*",
                        "arn:aws:s3:::startupo-analytics-*/*"
                    ]
                ),
                # RDS Read-Only Access
                iam.PolicyStatement(
                    sid="RDSReadOnlyAccess",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "rds:DescribeDBInstances",
                        "rds:DescribeDBClusters",
                        "rds:DescribeDBSnapshots",
                        "rds:ListTagsForResource"
                    ],
                    resources=["*"]
                ),
                # CloudWatch Read-Only for monitoring
                iam.PolicyStatement(
                    sid="CloudWatchReadOnly",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "cloudwatch:Describe*",
                        "cloudwatch:Get*",
                        "cloudwatch:List*",
                        "logs:DescribeLogGroups",
                        "logs:DescribeLogStreams"
                    ],
                    resources=["*"]
                )
            ]
        )
        
        analysts_group.add_managed_policy(analysts_policy)

        # ==========================================
        # MFA ENFORCEMENT POLICY
        # ==========================================
        
        mfa_policy = iam.ManagedPolicy(
            self, "MFAEnforcementPolicy",
            managed_policy_name="EnforceMFAPolicy",
            description="Requires MFA for all AWS actions except IAM/STS for MFA setup",
            statements=[
                # Allow users to manage their own MFA
                iam.PolicyStatement(
                    sid="AllowManageOwnMFA",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "iam:CreateVirtualMFADevice",
                        "iam:EnableMFADevice",
                        "iam:GetUser",
                        "iam:ListMFADevices",
                        "iam:ListVirtualMFADevices",
                        "iam:ResyncMFADevice"
                    ],
                    resources=[
                        Fn.sub("arn:aws:iam::${AWS::AccountId}:mfa/${aws:username}"),
                        Fn.sub("arn:aws:iam::${AWS::AccountId}:user/${aws:username}")
                    ]
                ),
                # Allow users to change their own password
                iam.PolicyStatement(
                    sid="AllowChangeOwnPassword",
                    effect=iam.Effect.ALLOW,
                    actions=[
                        "iam:ChangePassword",
                        "iam:GetAccountPasswordPolicy"
                    ],
                    resources=["*"]
                ),
                # Deny all other actions if MFA is not present
                iam.PolicyStatement(
                    sid="DenyAllExceptListedIfNoMFA",
                    effect=iam.Effect.DENY,
                    not_actions=[
                        "iam:CreateVirtualMFADevice",
                        "iam:EnableMFADevice",
                        "iam:GetUser",
                        "iam:ListMFADevices",
                        "iam:ListVirtualMFADevices",
                        "iam:ResyncMFADevice",
                        "iam:ChangePassword",
                        "iam:GetAccountPasswordPolicy",
                        "sts:GetSessionToken"
                    ],
                    resources=["*"],
                    conditions={
                        "BoolIfExists": {
                            "aws:MultiFactorAuthPresent": "false"
                        }
                    }
                )
            ]
        )
        
        # Attach MFA policy to all groups
        developers_group.add_managed_policy(mfa_policy)
        operations_group.add_managed_policy(mfa_policy)
        finance_group.add_managed_policy(mfa_policy)
        analysts_group.add_managed_policy(mfa_policy)

        # ==========================================
        # IAM USERS (Examples)
        # ==========================================
        
        developer_user = iam.User(
            self, "DeveloperUser1",
            user_name="dev-john-smith",
            groups=[developers_group]
        )
        
        operations_user = iam.User(
            self, "OperationsUser1",
            user_name="ops-jane-doe",
            groups=[operations_group]
        )
        
        finance_user = iam.User(
            self, "FinanceUser1",
            user_name="finance-manager",
            groups=[finance_group]
        )
        
        analyst_user = iam.User(
            self, "AnalystUser1",
            user_name="analyst-alice-wong",
            groups=[analysts_group]
        )

        # ==========================================
        # ACCOUNT PASSWORD POLICY
        # ==========================================
        
        # Note: CDK doesn't have a native L2 construct for password policy
        # You need to set this via AWS CLI:
        # aws iam update-account-password-policy --minimum-password-length 14 \
        #   --require-symbols --require-numbers --require-uppercase-characters \
        #   --require-lowercase-characters --max-password-age 90 \
        #   --password-reuse-prevention 5 --allow-users-to-change-password

        # ==========================================
        # OUTPUTS
        # ==========================================
        
        CfnOutput(
            self, "DevelopersGroupArn",
            value=developers_group.group_arn,
            description="ARN of the Developers IAM Group"
        )
        
        CfnOutput(
            self, "OperationsGroupArn",
            value=operations_group.group_arn,
            description="ARN of the Operations IAM Group"
        )
        
        CfnOutput(
            self, "FinanceGroupArn",
            value=finance_group.group_arn,
            description="ARN of the Finance IAM Group"
        )
        
        CfnOutput(
            self, "AnalystsGroupArn",
            value=analysts_group.group_arn,
            description="ARN of the Analysts IAM Group"
        )
        
        CfnOutput(
            self, "DevelopersPolicyArn",
            value=developers_policy.managed_policy_arn,
            description="ARN of the Developers Policy"
        )
        
        CfnOutput(
            self, "OperationsPolicyArn",
            value=operations_policy.managed_policy_arn,
            description="ARN of the Operations Policy"
        )
        
        CfnOutput(
            self, "FinancePolicyArn",
            value=finance_policy.managed_policy_arn,
            description="ARN of the Finance Policy"
        )
        
        CfnOutput(
            self, "AnalystsPolicyArn",
            value=analysts_policy.managed_policy_arn,
            description="ARN of the Analysts Policy"
        )
        
        CfnOutput(
            self, "MFAEnforcementPolicyArn",
            value=mfa_policy.managed_policy_arn,
            description="ARN of the MFA Enforcement Policy"
        )
```

---

## File 3: requirements.txt

Copy **EXACTLY THIS**:
```
aws-cdk-lib==2.100.0
constructs>=10.0.0,<11.0.0

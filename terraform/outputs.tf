output "developers_group_name" {
  description = "Name of the Developers IAM Group"
  value       = aws_iam_group.developers.name
}

output "developers_group_arn" {
  description = "ARN of the Developers IAM Group"
  value       = aws_iam_group.developers.arn
}

output "operations_group_name" {
  description = "Name of the Operations IAM Group"
  value       = aws_iam_group.operations.name
}

output "operations_group_arn" {
  description = "ARN of the Operations IAM Group"
  value       = aws_iam_group.operations.arn
}

output "finance_group_name" {
  description = "Name of the Finance IAM Group"
  value       = aws_iam_group.finance.name
}

output "finance_group_arn" {
  description = "ARN of the Finance IAM Group"
  value       = aws_iam_group.finance.arn
}

output "analysts_group_name" {
  description = "Name of the Analysts IAM Group"
  value       = aws_iam_group.analysts.name
}

output "analysts_group_arn" {
  description = "ARN of the Analysts IAM Group"
  value       = aws_iam_group.analysts.arn
}

output "developers_policy_arn" {
  description = "ARN of the Developers Policy"
  value       = aws_iam_policy.developers_policy.arn
}

output "operations_policy_arn" {
  description = "ARN of the Operations Policy"
  value       = aws_iam_policy.operations_policy.arn
}

output "finance_policy_arn" {
  description = "ARN of the Finance Policy"
  value       = aws_iam_policy.finance_policy.arn
}

output "analysts_policy_arn" {
  description = "ARN of the Analysts Policy"
  value       = aws_iam_policy.analysts_policy.arn
}

output "mfa_enforcement_policy_arn" {
  description = "ARN of the MFA Enforcement Policy"
  value       = aws_iam_policy.mfa_enforcement.arn
}

output "created_users" {
  description = "List of created IAM users"
  value = [
    aws_iam_user.developer_1.name,
    aws_iam_user.operations_1.name,
    aws_iam_user.finance_1.name,
    aws_iam_user.analyst_1.name
  ]
}

output "password_policy_summary" {
  description = "Summary of password policy settings"
  value = {
    minimum_length    = aws_iam_account_password_policy.strict.minimum_password_length
    max_age_days      = aws_iam_account_password_policy.strict.max_password_age
    reuse_prevention  = aws_iam_account_password_policy.strict.password_reuse_prevention
  }
}

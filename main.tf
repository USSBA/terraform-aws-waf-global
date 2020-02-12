terraform {
  required_version = "~> 0.12.9"
  required_providers {
    aws = "~> 2.30"
  }
}
data "aws_caller_identity" "current" {}
locals {
  # Current Account Id
  account_id = data.aws_caller_identity.current.account_id

  # Valid Actions
  actions = ["BLOCK", "COUNT"]

  # Determine if the SQLi rule is enabled
  is_sqli_enabled = var.enabled && contains(local.actions, var.rule_sqli) ? 1 : 0

  # Determine if the AuthToken rule is enabled
  is_auth_tokens_enabled = var.enabled && contains(local.actions, var.rule_auth_tokens) ? 1 : 0

  # Determine if the XSS rule is enabled
  is_xss_enabled = var.enabled && contains(local.actions, var.rule_xss) ? 1 : 0

  # Determine if the RFI/LFI rule is enabled
  is_rfi_lfi_enabled = var.enabled && contains(local.actions, var.rule_rfi_lfi) ? 1 : 0

  # Determine if the Admin Access rule is enabled
  is_admin_access_enabled = var.enabled && contains(local.actions, var.rule_admin_access) ? 1 : 0

  # Determine if the PHP rule is enabled
  is_php_enabled = var.enabled && contains(local.actions, var.rule_php) ? 1 : 0

  # Determine if the Size Constraints rule is enabled
  is_size_constraints_enabled = var.enabled && contains(local.actions, var.rule_size_constraints) ? 1 : 0

  # Determine if the CSRF rule is enabled
  is_csrf_enabled = var.enabled && contains(local.actions, var.rule_csrf) ? 1 : 0

  # Determine if the SSI rule is enabled
  is_ssi_enabled = var.enabled && contains(local.actions, var.rule_ssi) ? 1 : 0

  # Determine if the IP Blacklist rule is enabled
  is_ip_blacklist_enabled = var.enabled && contains(local.actions, var.rule_ip_blacklist) ? 1 : 0

  # Determine if Rate Limiting is enabled
  is_rate_limit_enabled = var.enabled && contains(local.actions, var.rule_rate_limit) ? 1 : 0

  # Determine if Kinesis Firehose Logs is enabled
  is_kinesis_firehose_logs_enabled = var.enabled && var.kinesis_firehose_logs_enabled ? 1 : 0
}

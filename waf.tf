

resource "aws_waf_web_acl" "waf_acl" {
  count       = var.enabled ? 1 : 0
  name        = "${var.waf_prefix}-generic-owasp-acl"
  metric_name = "${var.waf_prefix}genericowaspacl"

  # TODO
  # Log Configuration

  default_action {
    type = "Allow"
  }

  dynamic "rules" {
    iterator = x
    for_each = local.is_sqli_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_sqli
      }
      priority = var.rule_sqli_priority
      rule_id  = aws_waf_rule.mitigate_sqli.id
      type     = "REGULAR"
    }
  }
  dynamic "rules" {
    iterator = x
    for_each = local.is_auth_tokens_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_auth_tokens
      }
      priority = var.rule_auth_tokens_priority
      rule_id  = aws_waf_rule.detect_bad_auth_tokens.id
      type     = "REGULAR"
    }
  }
  dynamic "rules" {
    iterator = x
    for_each = local.is_xss_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_xss
      }
      priority = var.rule_xss_priority
      rule_id  = aws_waf_rule.mitigate_xss.id
      type     = "REGULAR"
    }
  }
  dynamic "rules" {
    iterator = x
    for_each = local.is_rfi_lfi_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_rfi_lfi
      }
      priority = var.rule_rfi_lfi_priority
      rule_id  = aws_waf_rule.detect_rfi_lfi_traversal.id
      type     = "REGULAR"
    }
  }

  # php
  dynamic "rules" {
    iterator = x
    for_each = local.is_php_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_php
      }
      priority = var.rule_php_priority
      rule_id  = aws_waf_rule.detect_php_insecure.id
      type     = "REGULAR"
    }
  }

  # size constraints
  dynamic "rules" {
    iterator = x
    for_each = local.is_size_constraints_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_size_constraints
      }
      priority = var.rule_size_constraints_priority
      rule_id  = aws_waf_rule.restrict_sizes.id
      type     = "REGULAR"
    }
  }






}

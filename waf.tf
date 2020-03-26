resource "aws_waf_web_acl" "waf_acl" {
  count       = var.enabled ? 1 : 0
  name        = "${var.waf_prefix}-generic-owasp-acl"
  metric_name = "${var.waf_prefix}genericowaspacl"

  # Dynamic block to allow optional configuration of logging_configuration
  dynamic "logging_configuration" {
    iterator = x
    for_each = aws_kinesis_firehose_delivery_stream.log_stream[*].arn
    content {
      log_destination = x.value
    }
  }


  default_action {
    type = "ALLOW"
  }

  # sql injection
  dynamic "rules" {
    iterator = x
    for_each = local.is_sqli_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_sqli
      }
      priority = var.rule_sqli_priority
      rule_id  = aws_waf_rule.mitigate_sqli[0].id
      type     = "REGULAR"
    }
  }

  # authorization tokens
  dynamic "rules" {
    iterator = x
    for_each = local.is_auth_tokens_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_auth_tokens
      }
      priority = var.rule_auth_tokens_priority
      rule_id  = aws_waf_rule.detect_bad_auth_tokens[0].id
      type     = "REGULAR"
    }
  }

  # corss site scripting
  dynamic "rules" {
    iterator = x
    for_each = local.is_xss_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_xss
      }
      priority = var.rule_xss_priority
      rule_id  = aws_waf_rule.mitigate_xss[0].id
      type     = "REGULAR"
    }
  }

  # path traversal (rfi-lfi)
  dynamic "rules" {
    iterator = x
    for_each = local.is_rfi_lfi_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_rfi_lfi
      }
      priority = var.rule_rfi_lfi_priority
      rule_id  = aws_waf_rule.detect_rfi_lfi_traversal[0].id
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
      rule_id  = aws_waf_rule.detect_php_insecure[0].id
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
      rule_id  = aws_waf_rule.restrict_sizes[0].id
      type     = "REGULAR"
    }
  }

  # cross site request forgery
  dynamic "rules" {
    iterator = x
    for_each = local.is_csrf_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_csrf
      }
      priority = var.rule_csrf_priority
      rule_id  = aws_waf_rule.enforce_csrf[0].id
      type     = "REGULAR"
    }
  }

  # server side includes
  dynamic "rules" {
    iterator = x
    for_each = local.is_ssi_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_ssi
      }
      priority = var.rule_ssi_priority
      rule_id  = aws_waf_rule.detect_ssi[0].id
      type     = "REGULAR"
    }
  }

  # ip blacklist
  dynamic "rules" {
    iterator = x
    for_each = local.is_ip_blacklist_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_ip_blacklist
      }
      priority = var.rule_ip_blacklist_priority
      rule_id  = aws_waf_rule.detect_blacklisted_ips[0].id
      type     = "REGULAR"
    }
  }

  # rate limiting
  dynamic "rules" {
    iterator = x
    for_each = local.is_rate_limit_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_rate_limit
      }
      priority = var.rule_rate_limit_priority
      rule_id  = aws_waf_rate_based_rule.rate_limit[0].id
      type     = "RATE_BASED"
    }
  }

  # country of origin
  dynamic "rules" {
    iterator = x
    for_each = local.is_country_of_origin_enabled == 1 ? ["enabled"] : []
    content {
      action {
        type = var.rule_country_of_origin
      }
      priority = var.rule_country_of_origin_priority
      rule_id  = aws_waf_rule.country_of_origin_filter[0].id
      type     = "REGULAR"
    }
  }
}
resource "aws_wafregional_web_acl_association" "acl_cloudfront_association" {
  depends_on   = [aws_waf_web_acl.waf_acl]
  count        = var.enabled == 1 ? length(var.cloudfront_arns) : 0
  resource_arn = element(var.cloudfront_arns, count.index)
  web_acl_id   = aws_waf_web_acl.waf_acl[0].id
}


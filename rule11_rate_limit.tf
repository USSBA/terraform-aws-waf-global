resource "aws_waf_rate_based_rule" "rate_limit" {
  count       = local.is_rate_limit_enabled
  name        = "${var.waf_prefix}-rate-limit"
  metric_name = "${var.waf_prefix}ratelimit"
  rate_key    = "IP"
  rate_limit  = var.rule_rate_limit_count
  predicates {
    data_id = aws_waf_byte_match_set.rate_limit[0].id
    negated = false
    type    = "ByteMatch"
  }
}
resource "aws_waf_byte_match_set" "rate_limit" {
  count = local.is_rate_limit_enabled
  name  = "${var.waf_prefix}-rate-limit"
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_rate_limit_paths
    content {
      target_string         = x.value
      text_transformation   = "LOWERCASE"
      positional_constraint = "STARTS_WITH"
      field_to_match {
        type = "URI"
      }
    }
  }
}

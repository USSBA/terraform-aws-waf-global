resource "aws_waf_rule" "detect_ssi" {
  count       = local.is_ssi_enabled
  name        = "${var.waf_prefix}-generic-detect-ssi"
  metric_name = "${var.waf_prefix}genericdetectssi"
  predicates {
    data_id = aws_waf_byte_match_set.match_ssi[0].id
    negated = false
    type    = "ByteMatch"
  }
}
resource "aws_waf_byte_match_set" "match_ssi" {
  count = local.is_ssi_enabled
  name  = "${var.waf_prefix}-generic-match-ssi"
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_ssi_file_extensions
    content {
      text_transformation   = "LOWERCASE"
      target_string         = lower(x.value)
      positional_constraint = "ENDS_WITH"
      field_to_match {
        type = "URI"
      }
    }
  }
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_ssi_paths
    content {
      text_transformation   = "URL_DECODE"
      target_string         = x.value
      positional_constraint = "STARTS_WITH"
      field_to_match {
        type = "URI"
      }
    }
  }
}


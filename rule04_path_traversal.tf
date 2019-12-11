resource "aws_waf_rule" "detect_rfi_lfi_traversal" {
  count       = local.is_rfi_lfi_enabled
  name        = "${var.waf_prefix}-generic-detect-rfi-lfi-traversal"
  metric_name = "${var.waf_prefix}genericdetectrfilfitraversal"

  predicates {
    data_id = aws_waf_byte_match_set.match_rfi_lfi_traversal[0].id
    negated = false
    type    = "ByteMatch"
  }
}
resource "aws_waf_byte_match_set" "match_rfi_lfi_traversal" {
  count = local.is_rfi_lfi_enabled
  name  = "${var.waf_prefix}-generic-detect-rfi-lfi-traversal"

  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_rfi_lfi_querystring
    content {
      text_transformation   = "HTML_ENTITY_DECODE"
      target_string         = x.value
      positional_constraint = "CONTAINS"
      field_to_match {
        type = "QUERY_STRING"
      }
    }
  }
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_rfi_lfi_querystring
    content {
      text_transformation   = "URL_DECODE"
      target_string         = x.value
      positional_constraint = "CONTAINS"
      field_to_match {
        type = "QUERY_STRING"
      }
    }
  }
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_rfi_lfi_uri
    content {
      text_transformation   = "HTML_ENTITY_DECODE"
      target_string         = x.value
      positional_constraint = "CONTAINS"
      field_to_match {
        type = "QUERY_STRING"
      }
    }
  }
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_rfi_lfi_uri
    content {
      text_transformation   = "URL_DECODE"
      target_string         = x.value
      positional_constraint = "CONTAINS"
      field_to_match {
        type = "QUERY_STRING"
      }
    }
  }
}

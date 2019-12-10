resource "aws_waf_rule" "mitigate_xss" {
  count       = local.is_xss_enabled
  name        = "${var.waf_prefix}-generic-mitigate-xss"
  metric_name = "${var.waf_prefix}genericmitigatexss"

  predicates {
    data_id = aws_waf_xss_match_set.xss_match_set[0].id
    negated = false
    type    = "XssMatch"

  }
}
resource "aws_waf_xss_match_set" "xss_match_set" {
  count = local.is_xss_enabled
  name  = "${var.waf_prefix}-generic-detect-xss"

  dynamic "xss_match_tuples" {
    iterator = x
    for_each = var.rule_xss_request_fields
    content {
      text_transformation = "HTML_ENTITY_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
  dynamic "xss_match_tuples" {
    iterator = x
    for_each = var.rule_xss_request_fields
    content {
      text_transformation = "URL_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
  dynamic "xss_match_tuples" {
    iterator = x
    for_each = var.rule_xss_request_headers
    content {
      text_transformation = "HTML_ENTITY_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
  dynamic "xss_match_tuples" {
    iterator = x
    for_each = var.rule_xss_request_headers
    content {
      text_transformation = "URL_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
}

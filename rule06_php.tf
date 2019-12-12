resource "aws_waf_rule" "detect_php_insecure" {
  count       = local.is_php_enabled
  name        = "${var.waf_prefix}-generic-detect-php-insecure"
  metric_name = "${var.waf_prefix}genericdetectphpinsecure"
  predicates {
    data_id = aws_waf_byte_match_set.match_php_insecure_uri[0].id
    negated = false
    type    = "ByteMatch"
  }
  predicates {
    data_id = aws_waf_byte_match_set.match_php_insecure_var_refs[0].id
    negated = false
    type    = "ByteMatch"
  }
}
resource "aws_waf_byte_match_set" "match_php_insecure_uri" {
  count = local.is_php_enabled
  name  = "${var.waf_prefix}-generic-match-php-insecure-uri"
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_php_insecure_uri_text_map
    content {
      text_transformation   = "URL_DECODE"
      target_string         = x.value.text
      positional_constraint = x.value.position
      field_to_match {
        type = "URI"
      }
    }
  }
}
resource "aws_waf_byte_match_set" "match_php_insecure_var_refs" {
  count = local.is_php_enabled
  name  = "${var.waf_prefix}-generic-match-php-insecure-var-refs"
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_php_insecure_query_string_parts
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

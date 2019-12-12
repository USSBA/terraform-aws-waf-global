# OWASP Top 10 - A1
# SQL Injection Attack
# Matches patterns in the request
# - BODY
# - QUERY_STRING
# - URI
# - HEADER[cookie]
# - HEADER[Authorization]
resource "aws_waf_rule" "mitigate_sqli" {
  count       = local.is_sqli_enabled
  name        = "${var.waf_prefix}-generic-mitigate-sqli"
  metric_name = "${var.waf_prefix}genericmitigatesqli"

  predicates {
    data_id = aws_waf_sql_injection_match_set.sql_injection_match_set[0].id
    negated = false
    type    = "SqlInjectionMatch"
  }
}
resource "aws_waf_sql_injection_match_set" "sql_injection_match_set" {
  count = local.is_sqli_enabled
  name  = "${var.waf_prefix}-generic-detect-sqli"
  dynamic "sql_injection_match_tuples" {
    iterator = x
    for_each = var.rule_sqli_request_fields
    content {
      text_transformation = "HTML_ENTITY_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
  dynamic "sql_injection_match_tuples" {
    iterator = x
    for_each = var.rule_sqli_request_fields
    content {
      text_transformation = "URL_DECODE"
      field_to_match {
        type = x.value
      }
    }
  }
  dynamic "sql_injection_match_tuples" {
    iterator = x
    for_each = var.rule_sqli_request_headers
    content {
      text_transformation = "HTML_ENTITY_DECODE"
      field_to_match {
        type = "HEADER"
        data = x.value
      }
    }
  }
  dynamic "sql_injection_match_tuples" {
    iterator = x
    for_each = var.rule_sqli_request_headers
    content {
      text_transformation = "URL_DECODE"
      field_to_match {
        type = "HEADER"
        data = x.value
      }
    }
  }
}

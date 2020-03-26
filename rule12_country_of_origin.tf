resource "aws_waf_rule" "country_of_origin_filter" {
  count       = local.is_country_of_origin_enabled
  name        = "${var.waf_prefix}-generic-country-of-origin-filter"
  metric_name = "${var.waf_prefix}genericcountryoforiginfilter"

  predicates {
    data_id = aws_waf_geo_match_set.geo_match_set[0].id
    negated = var.rule_country_of_origin_blacklist_or_whitelist != "blacklist"
    type    = "GeoMatch"
  }
  predicates {
    data_id = aws_waf_byte_match_set.geo_match_url[0].id
    negated = false
    type    = "ByteMatch"
  }
}

resource "aws_waf_geo_match_set" "geo_match_set" {
  count = local.is_country_of_origin_enabled
  name  = "${var.waf_prefix}-geo-match-set"

  dynamic "geo_match_constraint" {
    iterator = x
    for_each = var.rule_country_of_origin_set
    content {
      type  = "Country"
      value = x.value
    }
  }
}

resource "aws_waf_byte_match_set" "geo_match_url" {
  count = local.is_country_of_origin_enabled
  name  = "${var.waf_prefix}-geo-match-url"
  dynamic "byte_match_tuples" {
    iterator = x
    for_each = var.rule_country_of_origin_paths
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

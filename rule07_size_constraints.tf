resource "aws_waf_rule" "restrict_sizes" {
  count       = local.is_size_constraints_enabled
  name        = "${var.waf_prefix}-generic-restrict-sizes"
  metric_name = "${var.waf_prefix}genericrestrictsizes"

  predicates {
    data_id = aws_waf_size_constraint_set.size_restrictions[0].id
    negated = false
    type    = "SizeConstraint"
  }
}
resource "aws_waf_size_constraint_set" "size_restrictions" {
  count = local.is_size_constraints_enabled
  name  = "${var.waf_prefix}-generic-size-restrictions"
  dynamic "size_constraints" {
    iterator = x
    for_each = var.rule_size_constraints_field_map
    content {
      text_transformation = "NONE"
      comparison_operator = "GT"
      size                = x.value.size < 0 ? 0 : x.value.size > 21474836480 ? 21474836480 : x.value.size
      field_to_match {
        type = x.value.type
      }
    }
  }
  dynamic "size_constraints" {
    iterator = x
    for_each = var.rule_size_constraints_header_map
    content {
      text_transformation = "NONE"
      comparison_operator = "GT"
      size                = x.value.size < 0 ? 0 : x.value.size > 21474836480 ? 21474836480 : x.value.size
      field_to_match {
        type = "HEADER"
        data = x.value.type
      }
    }
  }
}


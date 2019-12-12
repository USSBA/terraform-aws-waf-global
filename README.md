# terraform-aws-waf-global

## Description
This project attempts to cover the OWASP top 10 rules and offers the flexibility to customize each rule to suit your applications needs.

```
module "waf_global" {
  source = "../../../terraform-aws-waf-global"

  enabled    = true
  waf_prefix = "${terraform.workspace}Global"
  cloudfront_arns = []

  # logging
  kinesis_firehose_logs_enabled           = false
  kinesis_firehose_log_bucket_arn         = aws_s3_bucket.waf_logs.arn
  kinesis_firehose_log_bucket_prefix      = "waf_global/"
  kinesis_firehose_log_compression_format = "GZIP"
  # request size constraints
  rule_size_constraints          = "COUNT"
  rule_size_constraints_priority = 10
  rule_size_constraints_field_map = [
    { size = 4096, type = "QUERY_STRING" },
    { size = 4096, type = "URI" },
  ]
  rule_size_constraints_header_map = [
    { size = 4096, type = "cookie" },
  ]
  # ip blacklist
  rule_ip_blacklist          = "DISABLED"
  rule_ip_blacklist_priority = 20
  rule_ip_blacklist_ipv4     = []
  rule_ip_blacklist_ipv6     = []
  # auth tokens
  rule_auth_tokens            = "DISABLED"
  rule_auth_tokens_priority   = 30
  rule_auth_tokens_black_list = []
  # sql injection
  rule_sqli                 = "BLOCK"
  rule_sqli_priority        = 40
  rule_sqli_request_fields  = ["BODY", "URI", "QUERY_STRING"]
  rule_sqli_request_headers = ["authorization"]
  # cross site scripting
  rule_xss                 = "COUNT"
  rule_xss_priority        = 50
  rule_xss_request_fields  = ["BODY", "URI", "QUERY_STRING"]
  rule_xss_request_headers = ["cookie"]
  # path traversal
  rule_rfi_lfi             = "BLOCK"
  rule_rfi_lfi_priority    = 60
  rule_rfi_lfi_querystring = ["://", "../"]
  rule_rfi_lfi_uri         = ["://", "../"]
  # php insecureties
  rule_php          = "BLOCK"
  rule_php_priority = 70
  rule_php_insecure_uri_text_map = [
    { text = "php", position = "ENDS_WITH" },
    { text = "/", position = "ENDS_WITH" },
  ]
  rule_php_insecure_query_string_parts = ["_ENV[", "_SERVER[", "allow_url_include=", "auto_append_file=", "auto_prepend_file=", "disable_functions=", "open_basedir=", "safe_mode="]
  # cross site request forgery
  rule_csrf          = "DISABLED"
  rule_csrf_priority = 80
  rule_csrf_header   = "x-csrf-token"
  rule_csrf_size     = 36
  # server-side includes
  rule_ssi                 = "COUNT"
  rule_ssi_priority        = 90
  rule_ssi_file_extensions = [".bak", ".backup", ".cfg", ".conf", ".config", ".ini", ".log"]
  # admin access
  rule_admin_access          = "DISABLED"
  rule_admin_access_priority = 100
  rule_admin_access_ipv4     = []
  rule_admin_access_ipv6     = []
  rule_admin_access_paths    = ["/admin"]
}

```

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

<sub>All contributions are subject to the license and in no way imply compensation   for contributions.</sub>


## Code of Conduct
We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:    HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.

<sub>The agency reserves the right to change this policy at any time.</sub>


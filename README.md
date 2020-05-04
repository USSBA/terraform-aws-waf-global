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
  # country_of_origin filter
  rule_country_of_origin = "COUNT"
  rule_country_of_origin_blacklist_or_whitelist = "whitelist"
  rule_country_of_origin_set = ["US"]
  rule_country_of_origin_paths = ["/my/sensitive/path/"] # List of path prefixes
}

```
## WAF Rules

### SQL Injection

[OWASP Top 10: SQL Injection](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A1-Injection)

Uses the AWS-managed SQL Injection detectors.  https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-sqli-match.html

In our experience, this can create a lot of false positives, so be sure to COUNT before you BLOCK

Example configuration:
```
  rule_sqli                 = "BLOCK"                         # BLOCK, COUNT, DISABLED
  rule_sqli_request_fields  = ["BODY", "URI", "QUERY_STRING"] # Which request fields do you want to check for potential attacks
  rule_sqli_request_headers = ["authorization"]               # Which headers do you want to check for potential attacks
```

### Authorization Token Blacklist

[OWASP Top 10: Broken Authentication](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A2-Broken_Authentication)

Ability to blacklist any hijacked or bad authorization token, such as something committed to GitHub.

It will block any request that include this in the `authorization` or `cookie` headers

Example configuration:
```
  rule_auth_tokens            = "BLOCK"
  rule_auth_tokens_black_list = ["ASDFASDFASDFASDFASDF", "QWERQWERQWERQWER"] # Blacklist these tokens from authorization or cookie headers
```

### Cross-Site Scripting (XSS)

[OWASP Top 10: Cross-site Scripting](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A7-Cross-Site_Scripting_%28XSS%29)

Uses the AWS-managed XSS Detectors.  https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-xss-match.html

In our experience, this can create a lot of false positives, so be sure to COUNT before you BLOCK

Example configuration:
```
  rule_xss                 = "BLOCK"
  rule_xss_request_fields  = ["BODY", "URI", "QUERY_STRING"]
  rule_xss_request_headers = ["cookie"]
```

### Cross-Site Request Forgery (CSRF)

Validates your POSTs have your CSRF token, which are used to defeat XSS

[OWASP Top 10: Cross-site Scripting](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A7-Cross-Site_Scripting_%28XSS%29)

Example configuration:
```
  rule_csrf          = "BLOCK"
  rule_csrf_header   = "x-csrf-token" # Name of your CSRF header
  rule_csrf_size     = 36             # Size of your CSRF header
```

### Path Traversal

[OWASP Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)

Example configuration:
```
  rule_rfi_lfi             = "BLOCK"
  rule_rfi_lfi_querystring = ["://", "../"]
  rule_rfi_lfi_uri         = ["://", "../"]
```

### Server-Side Includes

Blacklist of file suffixes that are not expected to be served from your application, but could
pose a security risk and are frequently targeted in attacks

Example configuration:
```
  rule_ssi                 = "BLOCK"
  rule_ssi_file_extensions = [".bak", ".backup", ".cfg", ".conf", ".config", ".ini", ".log"]
  rule_ssi_paths           = ["vulnerable/path"] # The paths this rule should apply to
```

### IP Blacklist

Blacklist CIDR range of IP and IPv6 addresses.  Helpful to mitigate an attack or block a source
of IPs.  For example, we have used this to block all of GCP when an attacker kept getting
new IP addresses from the service.

Example configuration:
```
  rule_ip_blacklist          = "BLOCK"
  rule_ip_blacklist_ipv4     = ["11.22.33.0/24"]
  rule_ip_blacklist_ipv6     = []
```

### Rate Limit

Enable rate limiting on a per-IP address basis.  The limit is over a 5-minute window.  All requests
beyond the `_count` limit amount over a 5 minute sliding window.  This counts all requests per IP,
so it's important to consider how many assets are on each page.

Example configuration:
```
  rule_rate_limit       = "BLOCK"
  rule_rate_limit_count = "2000"
  rule_rate_limit_paths = ["/app", "/non-static-content"]
```

### IP Whitelisted Paths ie: Admin Panel Restrictions

Allows you to restrict access to any path in your application using IP address CIDRs, adding an extra layer to an already restricted access panel

[OWASP Broken Access Control](https://owasp.org/www-project-top-ten/OWASP_Top_Ten_2017/Top_10-2017_A5-Broken_Access_Control)

Example configuration:
```
  rule_admin_access          = "BLOCK"
  # IP Address CIDRs to allow into admin paths
  rule_admin_access_ipv4     = [
    "111.222.33.0/24",  # Office IP Addresses
    "55.66.77.88/32",   # VPN IP Address
  ]
  rule_admin_access_ipv6     = []
  rule_admin_access_paths    = ["/admin"]
```

### Known PHP Vulnerabilities

Blocks requests with known some PHP vulnerabilities in the URL.  Recommended to use with default variables, but is configurable

Example configuration:
```
  rule_php = "BLOCK"
  rule_php_insecure_query_string_parts = ["_ENV[", "_SERVER[", "allow_url_include=", "auto_append_file=", "auto_prepend_file=", "disable_functions=", "open_basedir=", "safe_mode="]
```

### Restrict Request Size

Restricting request size can prevent a number of different attack vectors, such as buffer overflow or DDoS.

The size restrictions can be applied at different levels to the different fields of the request ("QUERY_STRING", "URI", "BODY", etc) or
can look at independent headers (such as "cookie")

Example configuration:
```
  rule_size_constraints = "BLOCK"

  rule_size_constraints_field_map = [
    { size = 4096, type = "QUERY_STRING" },
    { size = 4096, type = "URI" },
  ]
  rule_size_constraints_header_map = [
    { size = 4096, type = "cookie" },
  ]
```

### Direct Host Targeting prevention

If you use a CDN, you typically want all traffic going through the CDN and not to your
load balancer.  But people IP scan all AWS domains looking for vulnerable endpoints.  This
rule will block requests based on the Host header when they match direct ip targeting
or are an AWS hostname

Example configuration:
```
  rule_host_target = "BLOCK"
  # This matches the default config.  Requests that start with "ec2", are an IP address, or end with "amazonaws.com"
  rule_host_target_regex_patterns = ["^ec2", "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", "amazonaws.com$"]
```

### Country of Origin filtering

Allows you to block requests that come from a list of country codes.
With great power comes great responsibility.

Example configurations:
```
  # Blacklist
  rule_country_of_origin = "BLOCK"
  rule_country_of_origin_blacklist_or_whitelist = "blacklist"
  rule_country_of_origin_set = ["CN", "HK"]
```
```
  # Whitelist
  rule_country_of_origin = "BLOCK"
  rule_country_of_origin_blacklist_or_whitelist = "whitelist"
  rule_country_of_origin_set = ["US"]
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


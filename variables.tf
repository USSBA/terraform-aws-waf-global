# Common Variables
variable "enabled" {
  type        = bool
  description = "Toggles the creation or deletion of all resources within the module so that certain environmnets can be targeted."
  default     = true
}
variable "waf_prefix" {
  type        = string
  description = "A prefix to use for all named resources."
}
variable "cloudfront_arns" {
  type        = list(string)
  description = "A list of CloudFront ARNs to associate."
  default     = []
}

# Logging
variable "kinesis_firehose_logs_enabled" {
  default     = false
  description = "Enable/disable advanced logging with kinesis_firehose"
}
variable "kinesis_firehose_log_bucket_arn" {
  default     = "DISABLED"
  description = "S3 Bucket ARN"
}
variable "kinesis_firehose_log_bucket_prefix" {
  default     = ""
  description = "Advanced Logging S3 File Path/Prefix."
}
variable "kinesis_firehose_log_compression_format" {
  default     = "GZIP"
  description = "The compression format."
}

# sql injection
variable "rule_sqli" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_sqli_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 40
}
variable "rule_sqli_request_fields" {
  type        = list(string)
  description = "A list of fields in the request to look for SQLi attacks."
  default     = ["BODY", "URI", "QUERY_STRING"]
}
variable "rule_sqli_request_headers" {
  type        = list(string)
  description = "A list of headers in a request to look for SQLi attacks."
  default     = ["cookie", "authorization"]
}

# authorization tokens
variable "rule_auth_tokens" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_auth_tokens_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 30
}
variable "rule_auth_tokens_black_list" {
  type        = list(string)
  description = "A black list of values to look for in the Authorization and Cookie header of request."
  default     = []
}

# xss - cross site scripting
variable "rule_xss" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_xss_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 50
}
variable "rule_xss_request_fields" {
  type        = list(string)
  description = "A list of fields in the request to look for XSS attacks."
  default     = ["BODY", "URI", "QUERY_STRING"]
}
variable "rule_xss_request_headers" {
  type        = list(string)
  description = "A list of headers in the request to look for XSS attacks."
  default     = ["cookie"]
}

# csrf - cross site request forgery
variable "rule_csrf" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_csrf_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 80
}
variable "rule_csrf_header" {
  type        = string
  description = "The name of your CSRF token header."
  default     = "x-csrf-token"
}
variable "rule_csrf_size" {
  type        = number
  description = "The size of your CSRF token."
  default     = 36
}

# rfi lfi - path traversal
variable "rule_rfi_lfi" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_rfi_lfi_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 60
}
variable "rule_rfi_lfi_querystring" {
  type        = list(string)
  description = "A list of values to look for traversal attacks in the request querystring."
  default     = ["://", "../"]
}
variable "rule_rfi_lfi_uri" {
  type        = list(string)
  description = "A list of values to look for traversal attacks in the request URI."
  default     = ["://", "../"]
}

# admin access
variable "rule_admin_access" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_admin_access_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 100
}
variable "rule_admin_access_ipv4" {
  type        = list(string)
  description = "A whitelist of IPV4 cidr blocks that are permitted to access these paths."
  default     = []
}
variable "rule_admin_access_ipv6" {
  type        = list(string)
  description = "A whitelist of IPV6 cidr blocks that are permitted to access these paths."
  default     = []
}
variable "rule_admin_access_paths" {
  type        = list(string)
  description = "A black list of relative paths."
  default     = ["/admin"]
}

# php
variable "rule_php" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_php_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 70
}
variable "rule_php_insecure_uri_text_map" {
  type        = list(map(string))
  description = "A blacklist of text in a particular position within the URI of a request."
  default = [
    {
      text     = "php"
      position = "ENDS_WITH"
    },
    {
      text     = "/"
      position = "ENDS_WITH"
    },
  ]
}
variable "rule_php_insecure_query_string_parts" {
  type        = list(string)
  description = "A blacklist of text within the QUERYSTRING of a request."
  default = [
    "_ENV[",
    "_SERVER[",
    "allow_url_include=",
    "auto_append_file=",
    "auto_prepend_file=",
    "disable_functions=",
    "open_basedir=",
    "safe_mode="
  ]
}

# size constraints
variable "rule_size_constraints" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_size_constraints_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 10
}
variable "rule_size_constraints_field_map" {
  type        = list(map(string))
  description = "A map of fields and their associated size constrant in bytes. (0-21474836480)"
  default = [
    {
      size = 4096
      type = "BODY"
    },
    {
      size = 4096
      type = "QUERY_STRING"
    },
    {
      size = 4096
      type = "URI"
    }
  ]
}
variable "rule_size_constraints_header_map" {
  type        = list(map(string))
  description = "A map of headers and their associated size constrant in bytes. (0-21474836480)"
  default = [
    {
      size = 4096
      type = "cookie"
    }
  ]
}

# ssi - server-side includes
variable "rule_ssi" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_ssi_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 90
}
variable "rule_ssi_file_extensions" {
  type        = list(string)
  description = "A blacklist of file extensions within the URI of a request."
  default     = [".bak", ".backup", ".cfg", ".conf", ".config", ".ini", ".log"]
}
variable "rule_ssi_paths" {
  type        = list(string)
  description = "A blacklist of relative paths within the URI of a request."
  default     = ["/includes"]
}

# ip blacklist
variable "rule_ip_blacklist" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_ip_blacklist_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 20
}
variable "rule_ip_blacklist_ipv4" {
  type        = list(string)
  description = "A blacklist of IPV4 cidr blocks"
  default     = []
}
variable "rule_ip_blacklist_ipv6" {
  type        = list(string)
  description = "A blacklist of IPV6 cidr blocks"
  default     = []
}

# rate limiting
variable "rule_rate_limit" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_rate_limit_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 5
}
variable "rule_rate_limit_count" {
  type        = number
  description = "The number requests allowed over a 5 minute period (minimum value of 100 is enforced)"
  default     = 100
}
variable "rule_rate_limit_paths" {
  type        = list(string)
  description = "A list of relative URL paths to rate limit"
  default     = []
}

# country of origin
variable "rule_country_of_origin" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLED"
}
variable "rule_country_of_origin_blacklist_or_whitelist" {
  type        = string
  description = "Set this as a blacklist or whitelist"
  default     = "blacklist"
}
variable "rule_country_of_origin_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 6
}
variable "rule_country_of_origin_set" {
  type        = list(string)
  description = "A list of country codes to block/allow."
  default     = ["CN", "HK"]
}
variable "rule_country_of_origin_paths" {
  type        = list(string)
  description = "A list of paths to include in the waf rule. ex: [\"/my/sensitive/path\",\"/another/path\"]"
  default     = ["/*"]
}

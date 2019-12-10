# Common Variables
variable "enabled" {
  type        = bool
  description = "A toggle for creation of all resources in the module."
  default     = true
}
variable "waf_prefix" {
  type        = string
  description = "A prefix for all named resources."
  default     = "global"
}

# Rule: SQL Injection
variable "rule_sqli" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "BLOCK"
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

# Rule: Authorization Tokens
variable "rule_auth_tokens" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLE"
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

# Rule: Corss Site Scripting (XSS)
variable "rule_xss" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "BLOCK"
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

# Rule: Path Traversal
variable "rule_rfi_lfi" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "BLOCK"
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

# Rule: Admin Access
variable "rule_admin_access" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "DISABLE"
}
variable "rule_admin_access_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 100
}
variable "rule_admin_access_ipv4" {
  type        = list(string)
  description = "A white list of IPV4 cidr blocks"
  default     = []
}
variable "rule_admin_access_ipv6" {
  type        = list(string)
  description = "A white list of IPV6 cidr blocks"
  default     = []
}
variable "rule_admin_access_paths" {
  type        = list(string)
  description = "A black list of relative paths."
  default     = ["/admin", "/wp-admin"]
}

# Rule: PHP
variable "rule_php" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "BLOCK"
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
    "safe_mode=",
  ]
}

# Rule: Size Constraints
variable "rule_size_constraints" {
  type        = string
  description = "COUNT or BLOCK, any other value will disable this rule entirely."
  default     = "BLOCK"
}
variable "rule_size_constraints_priority" {
  type        = number
  description = "The priority in which to execute this rule."
  default     = 10
}
variable "rule_size_constraints_field_map" {
  type        = list(map(string))
  description = "A map of fields and their associated size constrant in bytes. (min: 0, max:21474836480)"
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
  description = "A map of headers and their associated size constrant in bytes. (min: 0, max:21474836480)"
  default = [
    {
      size = 4096
      type = "cookie"
    }
  ]
}

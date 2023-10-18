resource "aws_wafv2_ip_set" "cloudfront_cidrs_regional" {
  name               = "cloudfront_cidrs"
  description        = "Cloudfront CIDRs"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["120.52.22.96/27","205.251.249.0/24","180.163.57.128/26"]
}

resource "aws_wafv2_ip_set" "cloudfront_cidrs_global" {
  name               = "cloudfront_cidrs"
  description        = "Cloudfront CIDRs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = ["120.52.22.96/27","205.251.249.0/24","180.163.57.128/26"]
}


resource "aws_wafv2_rule_group" "firewall_manager_global" {
  provider   = aws.global
  capacity   = 100
  name       = "firewall-manager-global"
  scope      = "CLOUDFRONT"

  rule {
    name     = "AuthorizationHeaderRule"
    priority = 1

    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = data.aws_secretsmanager_secret_version.secret_header_current.secret_string
            field_to_match {
              single_header {
                name = "x-origin-verify"
              }
            }
            text_transformation {
              priority = 2
              type     = "NONE"
            }
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = data.aws_secretsmanager_secret_version.secret_header_previous.secret_string
            field_to_match {
              single_header {
                name = "x-origin-verify"
              }
            }
            text_transformation {
              priority = 2
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AuthorizationHeaderRule"
      sampled_requests_enabled   = false
    }
  }
  rule {
    name     = "whitelist_cloudfront_cidrs_ipv4"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cloudfront_cidrs_global.arn
      }
    }

    visibility_config {
      metric_name                = "whitelist_cloudfront_cidrs_ipv4"
      cloudwatch_metrics_enabled = false
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "AuthorizationHeaderRuleGroup"
    sampled_requests_enabled   = false
  }
}


resource "aws_wafv2_rule_group" "firewall_manager_frankfurt" {
  capacity   = 100
  name       = "firewall-manager-regional"
  scope      = "REGIONAL"

  rule {
    name     = "AuthorizationHeaderRule"
    priority = 1

    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = data.aws_secretsmanager_secret_version.secret_header_current.secret_string
            field_to_match {
              single_header {
                name = "x-origin-verify"
              }
            }
            text_transformation {
              priority = 2
              type     = "NONE"
            }
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = data.aws_secretsmanager_secret_version.secret_header_previous.secret_string
            field_to_match {
              single_header {
                name = "x-origin-verify"
              }
            }
            text_transformation {
              priority = 2
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AuthorizationHeaderRule"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "whitelist_cloudfront_regional_cidrs_ipv4"
    priority = 2

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.cloudfront_cidrs_regional.arn
      }
    }

    visibility_config {
      metric_name                = "whitelist_cloudfront_regional_cidrs_ipv4"
      cloudwatch_metrics_enabled = false
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "AuthorizationHeaderRuleGroup"
    sampled_requests_enabled   = false
  }
}

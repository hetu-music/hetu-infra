data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "use_origin_cache_control_headers_query_strings" {
  name = "UseOriginCacheControlHeaders-QueryStrings"
}

locals {
  managed_cache_policies = {
    "CachingOptimized"                          = data.aws_cloudfront_cache_policy.caching_optimized.id
    "CachingDisabled"                           = data.aws_cloudfront_cache_policy.caching_disabled.id
    "UseOriginCacheControlHeaders-QueryStrings" = data.aws_cloudfront_cache_policy.use_origin_cache_control_headers_query_strings.id
  }

  managed_origin_request_policies = {
    "AllViewer"                 = data.aws_cloudfront_origin_request_policy.all_viewer.id
    "AllViewerExceptHostHeader" = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
  }
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "this" {
  for_each = var.distributions

  enabled         = true
  is_ipv6_enabled = true
  comment         = each.value.comment
  price_class     = "PriceClass_All"
  aliases         = each.value.aliases
  http_version    = "http2and3"

  origin {
    domain_name = each.value.origin_domain_name
    origin_id   = each.value.origin_id
    origin_path = each.value.origin_path

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = each.value.origin_id

    viewer_protocol_policy = "https-only"
    compress               = true

    cache_policy_id          = lookup(local.managed_cache_policies, each.value.cache_policy_id, coalesce(each.value.cache_policy_id, data.aws_cloudfront_cache_policy.caching_disabled.id))
    origin_request_policy_id = lookup(local.managed_origin_request_policies, each.value.origin_request_policy_id, coalesce(each.value.origin_request_policy_id, data.aws_cloudfront_origin_request_policy.all_viewer.id))

    dynamic "grpc_config" {
      for_each = each.value.grpc_enabled ? [1] : []
      content {
        enabled = true
      }
    }

    dynamic "function_association" {
      for_each = concat(
        each.value.enable_security_guard ? [{
          event_type   = "viewer-request"
          function_arn = aws_cloudfront_function.security_guard[each.key].arn
        }] : [],
        each.value.function_associations
      )
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = each.value.geo_restriction.restriction_type
      locations        = each.value.geo_restriction.restriction_type != "none" ? each.value.geo_restriction.locations : []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = each.value.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-${each.key}-cloudfront" },
    each.value.tags
  )
}

resource "aws_cloudfront_function" "security_guard" {
  for_each = {
    for k, v in var.distributions : k => v
    if v.enable_security_guard
  }

  name    = "${var.name}-${each.key}-security-guard"
  runtime = "cloudfront-js-2.0"
  comment = "Security inspection function for ${var.name}-${each.key}"
  publish = true
  code    = file("${path.module}/functions/security_guard.js")
}


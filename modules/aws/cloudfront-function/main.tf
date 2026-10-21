resource "aws_cloudfront_function" "this" {
  name    = "${var.name}-${var.function_name}"
  runtime = var.runtime
  comment = var.comment
  publish = var.publish
  code    = var.code

  tags = merge(var.tags, { Name = "${var.name}-${var.function_name}" })
}


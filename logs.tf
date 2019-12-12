data "aws_iam_policy_document" "firehose_policy" {
  count = local.is_kinesis_firehose_logs_enabled
  statement {
    sid = "SendStreamToBucket"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      var.kinesis_firehose_log_bucket_arn,
      "${var.kinesis_firehose_log_bucket_arn}/${var.kinesis_firehose_log_bucket_prefix}*",
    ]
  }
  statement {
    sid = "UseTheStream"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.log_stream[0].arn,
    ]
  }
}
data "aws_iam_policy_document" "firehose_principal" {
  count = local.is_kinesis_firehose_logs_enabled
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        local.account_id
      ]
    }
  }
}
resource "aws_iam_role" "firehose_role" {
  count              = local.is_kinesis_firehose_logs_enabled
  name               = "${var.waf_prefix}_waf_firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_principal[0].json
}
resource "aws_iam_role_policy" "firehose" {
  count  = local.is_kinesis_firehose_logs_enabled
  name   = "${var.waf_prefix}-waf-firehose-policy"
  role   = aws_iam_role.firehose_role[0].id
  policy = data.aws_iam_policy_document.firehose_policy[0].json
}
resource "aws_kinesis_firehose_delivery_stream" "log_stream" {
  count       = local.is_kinesis_firehose_logs_enabled
  name        = "aws-waf-logs-${var.waf_prefix}"
  destination = "s3"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role[0].arn
    bucket_arn         = var.kinesis_firehose_log_bucket_arn
    compression_format = var.kinesis_firehose_log_compression_format
    prefix             = var.kinesis_firehose_log_bucket_prefix
  }
}


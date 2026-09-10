resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub OIDC root CA thumbprint
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = merge(var.tags, { Name = "${var.name}-github-oidc" })
}

locals {
  default_existing_oidc_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  oidc_provider_arn         = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : (var.existing_github_oidc_provider_arn != "" ? var.existing_github_oidc_provider_arn : local.default_existing_oidc_arn)
}

# Role 1: hetu-infra CI role (Terraform Plan & Apply)

resource "aws_iam_role" "hetu_infra_ci" {
  name               = "${var.name}-ci"
  assume_role_policy = data.aws_iam_policy_document.hetu_infra_ci_trust.json
  tags               = merge(var.tags, { Name = "${var.name}-ci" })
}

data "aws_iam_policy_document" "hetu_infra_ci_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.infra_repo}:*",
        "repo:${split("/", var.infra_repo)[0]}*/${split("/", var.infra_repo)[1]}*:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "hetu_infra_ci" {
  name   = "${var.name}-ci"
  role   = aws_iam_role.hetu_infra_ci.id
  policy = data.aws_iam_policy_document.hetu_infra_ci_permissions.json
}

data "aws_iam_policy_document" "hetu_infra_ci_permissions" {
  statement {
    sid    = "StateBackend"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket}",
      "arn:aws:s3:::${var.state_bucket}/*",
    ]
  }

  statement {
    sid    = "ManageInfra"
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "rds:*",
      "secretsmanager:*",
      "ssm:*",
      "logs:*",
      "acm:*",
    ]
    resources = ["*"]
  }

  statement {
    # Scoped to roles and instance profiles with project name prefix
    sid    = "IamForInstanceProfile"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.name}-*",
    ]
  }
}

# Role 2: Ansible deployment via SSM (kato-config CI)
resource "aws_iam_role" "hetu_config_ci" {
  name               = "${var.name}-config-ci"
  assume_role_policy = data.aws_iam_policy_document.hetu_config_ci_trust.json
  tags               = merge(var.tags, { Name = "${var.name}-config-ci" })
}

data "aws_iam_policy_document" "hetu_config_ci_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.config_repo}:*",
        "repo:${split("/", var.config_repo)[0]}*/${split("/", var.config_repo)[1]}*:*",
      ]
    }
  }
}

resource "aws_iam_role_policy" "hetu_config_ci" {
  name   = "${var.name}-config-ci"
  role   = aws_iam_role.hetu_config_ci.id
  policy = data.aws_iam_policy_document.hetu_config_ci_permissions.json
}

data "aws_iam_policy_document" "hetu_config_ci_permissions" {
  statement {
    sid    = "SsmConnectToTaggedInstance"
    effect = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:TerminateSession",
      "ssm:ResumeSession",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*",
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:document/AWS-StartSSHSession",
    ]
    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Project"
      values   = [var.name]
    }
  }

  statement {
    sid    = "SsmSessionDescribe"
    effect = "Allow"
    actions = [
      "ssm:DescribeSessions",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceInformation",
    ]
    resources = ["*"]
  }

  statement {
    # EC2 inventory discovery for Ansible
    sid    = "InventoryDiscovery"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }
}

# Role 3: EC2 Instance Role & Profile (SSM + Secrets/SSM access)

# 1. Base IAM role for the EC2 instance
resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
  tags               = merge(var.tags, { Name = "${var.name}-ec2" })
}

# 2. Instance profile wrapper to attach to the Launch Template in the aws/compute stack
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2"
  role = aws_iam_role.ec2.name
  tags = merge(var.tags, { Name = "${var.name}-ec2" })
}

# 3. Attach AWS managed policy for SSM Session Manager
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Attach scoped app permissions (secrets and parameter store access)
resource "aws_iam_role_policy" "ec2" {
  name   = "${var.name}-ec2"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.ec2_permissions.json
}

# -------------------------------------------------------------------------------------
# Policy documents referenced by the resources above
# -------------------------------------------------------------------------------------

# Trust policy: only the EC2 service can assume this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# App permissions: read secrets, parameters, and decrypt KMS
data "aws_iam_policy_document" "ec2_permissions" {
  statement {
    sid       = "ReadAppSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.name}/*"]
  }

  statement {
    sid    = "ReadAppParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_parameter_prefix}/*"]
  }

  statement {
    # SecureString parameters are KMS-encrypted under the account's default aws/ssm key.
    sid       = "DecryptSecureStringParameters"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/aws/ssm"]
  }
}

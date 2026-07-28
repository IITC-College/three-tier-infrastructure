# A token.actions.githubusercontent.com OIDC provider already exists in
# this AWS account from unrelated prior work (IAM allows only one provider
# per issuer URL, and multiple roles may trust the same provider) - reused
# via data source rather than recreated. Separate trust from Stage 2's
# app.terraform.io provider - don't conflate the two.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# --- backend-deploy: ECR push + ECS RegisterTaskDefinition/UpdateService only ---

data "aws_iam_policy_document" "backend_deploy_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.backend_repo_name}:ref:refs/heads/${var.deploy_branch}"]
    }
  }
}

resource "aws_iam_role" "backend_deploy" {
  name               = "${var.name_prefix}-backend-deploy"
  assume_role_policy = data.aws_iam_policy_document.backend_deploy_trust.json
}

data "aws_iam_policy_document" "backend_deploy_permissions" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPush"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    sid    = "EcsDeploy"
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
    ]
    # RegisterTaskDefinition/DescribeTaskDefinition don't support
    # resource-level restriction in IAM - scoped by action set instead.
    resources = ["*"]
  }

  statement {
    sid    = "EcsUpdateService"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]
    resources = [var.ecs_service_arn]
  }

  statement {
    sid       = "PassEcsRoles"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [var.task_execution_role_arn, var.task_role_arn]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "backend_deploy" {
  name   = "${var.name_prefix}-backend-deploy"
  role   = aws_iam_role.backend_deploy.id
  policy = data.aws_iam_policy_document.backend_deploy_permissions.json
}

# --- frontend-deploy: S3 sync + CloudFront invalidation only ---

data "aws_iam_policy_document" "frontend_deploy_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.frontend_repo_name}:ref:refs/heads/${var.deploy_branch}"]
    }
  }
}

resource "aws_iam_role" "frontend_deploy" {
  name               = "${var.name_prefix}-frontend-deploy"
  assume_role_policy = data.aws_iam_policy_document.frontend_deploy_trust.json
}

data "aws_iam_policy_document" "frontend_deploy_permissions" {
  statement {
    sid    = "S3Sync"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${var.frontend_bucket_arn}/*"]
  }

  statement {
    sid       = "S3List"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.frontend_bucket_arn]
  }

  statement {
    sid    = "CloudFrontInvalidate"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]
    resources = [var.cloudfront_distribution_arn]
  }
}

resource "aws_iam_role_policy" "frontend_deploy" {
  name   = "${var.name_prefix}-frontend-deploy"
  role   = aws_iam_role.frontend_deploy.id
  policy = data.aws_iam_policy_document.frontend_deploy_permissions.json
}

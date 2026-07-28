terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Local state on purpose: this is the one config that stands up the
  # trust HCP Terraform itself relies on, so it can't run *through* HCP
  # Terraform (chicken-and-egg). Not touched again after Stage 2.
}

provider "aws" {
  region = var.aws_region
}

data "tls_certificate" "tfc" {
  url = "https://${var.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "tfc" {
  url             = "https://${var.tfc_hostname}"
  client_id_list  = [var.tfc_aws_audience]
  thumbprint_list = [data.tls_certificate.tfc.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "tfc_run_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.tfc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.tfc_hostname}:aud"
      values   = [var.tfc_aws_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${var.tfc_hostname}:sub"
      values = [
        for ws in var.tfc_workspace_names :
        "organization:${var.tfc_organization}:project:*:workspace:${ws}:run_phase:*"
      ]
    }
  }
}

resource "aws_iam_role" "tfc_run" {
  name               = "three-tier-lab-tfc-run"
  assume_role_policy = data.aws_iam_policy_document.tfc_run_trust.json
}

# Broad permissions on purpose: this role provisions the entire stack
# (VPC/RDS/ECS/S3/CloudFront/IAM/...) for a solo lab AWS account. The real
# security boundary is the trust policy above, scoped to exactly these two
# workspace names — revisit before this pattern ever touches a
# shared/production AWS account.
resource "aws_iam_role_policy_attachment" "tfc_run_admin" {
  role       = aws_iam_role.tfc_run.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "tfc_run_role_arn" {
  value = aws_iam_role.tfc_run.arn
}

output "tfc_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.tfc.arn
}

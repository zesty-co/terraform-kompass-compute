data "aws_iam_policy_document" "hiberscaler" {
  count = local.use_hiberscaler_policy ? 1 : 0

  statement {
    sid = "AllowManageResumeQueues"
    resources = [
      "arn:${local.partition}:sqs:${local.region}:${local.account_id}:QScaler-resume-events-*",
    ]

    actions = [
      "sqs:CreateQueue",
      "sqs:DeleteMessage",
      "sqs:DeleteQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:TagQueue",
    ]
  }

  statement {
    sid = "AllowECRAccess"
    resources = [
      "*",
    ]
    actions = [
      "ecr-public:GetAuthorizationToken",
      "ecr:GetAuthorizationToken",
    ]
  }

  statement {
    sid = "AllowECRImagePulling"
    resources = [
      # Allow access to ECR images from different accounts and region
      "*",
    ]
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchImportUpstreamImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }

  statement {
    sid = "AllowReadingFromInterruptionQueue"
    resources = [
      "arn:${local.partition}:sqs:${local.region}:${local.account_id}:${var.sqs_queue_name}",
    ]

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
  }

  # Autodiscovery
  statement {
    sid = "AllowEC2Describre"
    resources = [
      "*",
    ]

    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeIamInstanceProfileAssociations",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcEndpoints",
    ]
  }

  # Allow reading instance attributes
  statement {
    sid = "AllowEC2DescribeInstanceAttribute"

    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
    ]

    actions = [
      "ec2:DescribeInstanceAttribute",
    ]

    condition {
      test     = "StringLike"
      values   = [var.cluster_name]
      variable = "aws:ResourceTag/qubex.ai/cluster-name"
    }
  }

  # EKS Discovery
  statement {
    sid = "AllowEKSDescribe"
    resources = [
      "arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}",
    ]

    actions = [
      "eks:DescribeCluster"
    ]
  }

  statement {
    sid = "AlloNodePoolDiscovery"
    resources = [
      "*",
    ]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplates",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "iam:GetInstanceProfile",
    ]
  }

  # VM Management
  statement {
    sid = "AllowPassRole"

    resources = [
      "*",
    ]

    actions = [
      "iam:PassRole",
    ]
  }

  statement {
    sid = "AllowLaunchInstance"
    resources = [
      "*",
    ]

    actions = [
      "ec2:CreateTags",
      "ec2:ModifyInstanceAttribute",
      "ec2:RunInstances",
    ]
  }

  statement {
    sid = "AllowManageInstance"
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
    ]

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
    ]

    condition {
      test     = "StringLike"
      values   = [var.cluster_name]
      variable = "aws:ResourceTag/qubex.ai/cluster-name"
    }
  }
}

data "aws_iam_policy_document" "snapshooter" {
  count = local.use_snapshooter_policy ? 1 : 0

  statement {
    sid = "AllowEC2Describre"
    resources = [
      "*",
    ]
    actions = [
      "ec2:DescribeInstances",
    ]
  }

  statement {
    sid = "AllowEC2Logs"
    resources = [
      "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*",
    ]

    actions = [
      "ec2:GetConsoleOutput",
    ]

    condition {
      test     = "StringLike"
      values   = [var.cluster_name]
      variable = "aws:ResourceTag/qubex.ai/cluster-name"
    }
  }
}

data "aws_iam_policy_document" "telemetry_manager" {
  count = local.use_telemetry_manager_policy ? 1 : 0

  statement {
    sid = "AllowEC2Logs"
    resources = [
      "*",
    ]

    actions = [
      "ec2:DescribeInstanceTypes"
    ]
  }
}

data "aws_iam_policy_document" "image_size_calculator" {
  count = local.use_image_size_calculator_policy ? 1 : 0

  statement {
    sid = "AllowVPCEndpointDiscovery"

    resources = [
      "*",
    ]

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeVpcEndpoints",
    ]
  }

  statement {
    sid = "AllowECRAccess"
    resources = [
      "*",
    ]
    actions = [
      "ecr-public:GetAuthorizationToken",
      "ecr:GetAuthorizationToken",
    ]
  }

  statement {
    sid = "AllowECRImagePulling"
    resources = [
      # Allow access to ECR images from different accounts and region
      "*",
    ]
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchImportUpstreamImage",
      "ecr:GetDownloadUrlForLayer",
    ]
  }

  statement {
    sid = "AllowManageECRPullThroughCache"

    resources = [
      "arn:${local.partition}:ecr:${local.region}:${local.account_id}:repository/*",
    ]

    actions = [
      "ecr:CreateRepository",
    ]
  }
}

data "aws_iam_policy_document" "controller" {
  count = var.create ? 1 : 0

  source_policy_documents = compact([
    local.use_hiberscaler_policy ? data.aws_iam_policy_document.hiberscaler[0].json : null,
    local.use_snapshooter_policy ? data.aws_iam_policy_document.snapshooter[0].json : null,
    local.use_telemetry_manager_policy ? data.aws_iam_policy_document.telemetry_manager[0].json : null,
    local.use_image_size_calculator_policy ? data.aws_iam_policy_document.image_size_calculator[0].json : null,
  ])

  dynamic "statement" {
    for_each = var.iam_policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

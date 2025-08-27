locals {
  create_hiberscaler_iam_role           = var.create && var.create_hiberscaler_iam_role
  create_snapshooter_iam_role           = var.create && var.create_snapshooter_iam_role
  create_telemetry_manager_iam_role     = var.create && var.create_telemetry_manager_iam_role
  create_image_size_calculator_iam_role = var.create && var.create_image_size_calculator_iam_role

  # Tags used for all resources
  tags = {
    Zesty = "true"
  }
}

################################################################################
# Kompass Compute IAM Roles
################################################################################

module "iam_hiberscaler" {
  source = "./modules/iam"

  create                            = local.create_hiberscaler_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_hiberscaler_role_name
  iam_role_use_name_prefix          = var.iam_hiberscaler_role_use_name_prefix
  iam_role_path                     = var.iam_hiberscaler_role_path
  iam_role_description              = var.iam_hiberscaler_role_description
  iam_role_max_session_duration     = var.iam_hiberscaler_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_hiberscaler_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_hiberscaler_role_tags
  iam_policy_name                   = var.iam_hiberscaler_policy_name
  iam_policy_use_name_prefix        = var.iam_hiberscaler_policy_use_name_prefix
  iam_policy_path                   = var.iam_hiberscaler_policy_path
  iam_policy_description            = var.iam_hiberscaler_policy_description
  iam_policy_statements             = var.iam_hiberscaler_policy_statements
  iam_use_hiberscaler_policy        = true
  iam_role_policies                 = var.iam_hiberscaler_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_hiberscaler_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.hiberscaler_service_account_name

  sqs_queue_name = local.queue_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_image_size_calculator" {
  source = "./modules/iam"

  create                               = local.create_image_size_calculator_iam_role
  cluster_name                         = var.cluster_name
  iam_role_name                        = var.iam_image_size_calculator_role_name
  iam_role_use_name_prefix             = var.iam_image_size_calculator_role_use_name_prefix
  iam_role_path                        = var.iam_image_size_calculator_role_path
  iam_role_description                 = var.iam_image_size_calculator_role_description
  iam_role_max_session_duration        = var.iam_image_size_calculator_role_max_session_duration
  iam_role_permissions_boundary_arn    = var.iam_image_size_calculator_role_permissions_boundary_arn
  iam_role_tags                        = var.iam_image_size_calculator_role_tags
  iam_policy_name                      = var.iam_image_size_calculator_policy_name
  iam_policy_use_name_prefix           = var.iam_image_size_calculator_policy_use_name_prefix
  iam_policy_path                      = var.iam_image_size_calculator_policy_path
  iam_policy_description               = var.iam_image_size_calculator_policy_description
  iam_policy_statements                = var.iam_image_size_calculator_policy_statements
  iam_use_image_size_calculator_policy = true
  iam_role_policies                    = var.iam_image_size_calculator_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_image_size_calculator_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.image_size_calculator_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_snapshooter" {
  source = "./modules/iam"

  create                            = local.create_snapshooter_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_snapshooter_role_name
  iam_role_use_name_prefix          = var.iam_snapshooter_role_use_name_prefix
  iam_role_path                     = var.iam_snapshooter_role_path
  iam_role_description              = var.iam_snapshooter_role_description
  iam_role_max_session_duration     = var.iam_snapshooter_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_snapshooter_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_snapshooter_role_tags
  iam_policy_name                   = var.iam_snapshooter_policy_name
  iam_policy_use_name_prefix        = var.iam_snapshooter_policy_use_name_prefix
  iam_policy_path                   = var.iam_snapshooter_policy_path
  iam_policy_description            = var.iam_snapshooter_policy_description
  iam_policy_statements             = var.iam_snapshooter_policy_statements
  iam_use_snapshooter_policy        = true
  iam_role_policies                 = var.iam_snapshooter_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_snapshooter_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.snapshooter_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

module "iam_telemetry_manager" {
  source = "./modules/iam"

  create                            = local.create_telemetry_manager_iam_role
  cluster_name                      = var.cluster_name
  iam_role_name                     = var.iam_telemetry_manager_role_name
  iam_role_use_name_prefix          = var.iam_telemetry_manager_role_use_name_prefix
  iam_role_path                     = var.iam_telemetry_manager_role_path
  iam_role_description              = var.iam_telemetry_manager_role_description
  iam_role_max_session_duration     = var.iam_telemetry_manager_role_max_session_duration
  iam_role_permissions_boundary_arn = var.iam_telemetry_manager_role_permissions_boundary_arn
  iam_role_tags                     = var.iam_telemetry_manager_role_tags
  iam_policy_name                   = var.iam_telemetry_manager_policy_name
  iam_policy_use_name_prefix        = var.iam_telemetry_manager_policy_use_name_prefix
  iam_policy_path                   = var.iam_telemetry_manager_policy_path
  iam_policy_description            = var.iam_telemetry_manager_policy_description
  iam_policy_statements             = var.iam_telemetry_manager_policy_statements
  iam_use_telemetry_manager_policy  = true
  iam_role_policies                 = var.iam_telemetry_manager_role_policies

  enable_irsa                     = var.enable_irsa
  irsa_oidc_provider_arn          = var.irsa_oidc_provider_arn
  irsa_namespace_service_accounts = var.irsa_telemetry_manager_namespace_service_accounts
  irsa_assume_role_condition_test = var.irsa_assume_role_condition_test

  enable_pod_identity             = var.enable_pod_identity
  create_pod_identity_association = var.create_pod_identity_association
  namespace                       = var.namespace
  service_account_name            = var.telemetry_manager_service_account_name

  tags = merge(
    local.tags,
    var.tags,
  )
}

################################################################################
# Node Termination Queue
################################################################################

locals {
  enable_spot_termination = var.create && var.enable_spot_termination

  queue_name = coalesce(var.queue_name, "ZestyKompassCompute-${var.cluster_name}")
}

resource "aws_sqs_queue" "this" {
  count = local.enable_spot_termination ? 1 : 0

  name                              = local.queue_name
  message_retention_seconds         = 300
  sqs_managed_sse_enabled           = var.queue_managed_sse_enabled ? var.queue_managed_sse_enabled : null
  kms_master_key_id                 = var.queue_kms_master_key_id
  kms_data_key_reuse_period_seconds = var.queue_kms_data_key_reuse_period_seconds

  tags = merge(
    local.tags,
    var.tags,
  )
}

data "aws_iam_policy_document" "queue" {
  count = local.enable_spot_termination ? 1 : 0

  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[0].arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this[0].arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  count = local.enable_spot_termination ? 1 : 0

  queue_url = aws_sqs_queue.this[0].url
  policy    = data.aws_iam_policy_document.queue[0].json
}

################################################################################
# Node Termination Event Rules
################################################################################

locals {
  events = {
    spot_interrupt = {
      name        = "SpotInterrupt"
      description = "Kompass Compute interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  name_prefix   = "${var.rule_name_prefix}${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = merge(
    local.tags,
    var.tags,
  )
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.events : k => v if local.enable_spot_termination }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "ZestyKompassComputeInterruptionQueueTarget"
  arn       = aws_sqs_queue.this[0].arn
}

################################################################################
# S3 VPC Endpoint
################################################################################

locals {
  create_s3_vpc_endpoint = var.create && var.create_s3_vpc_endpoint
  security_group_ids     = local.create_s3_vpc_endpoint_security_group ? concat(var.vpc_endpoint_security_group_ids, [aws_security_group.this[0].id]) : var.vpc_endpoint_security_group_ids
}

data "aws_vpc_endpoint_service" "this" {
  count = local.create_s3_vpc_endpoint ? 1 : 0

  service      = "s3"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "this" {
  count = local.create_s3_vpc_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.this[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = local.security_group_ids
  subnet_ids          = var.subnet_ids
  policy              = var.vpc_endpoint_policy
  private_dns_enabled = var.vpc_endpoint_private_dns_enabled
  ip_address_type     = var.vpc_endpoint_ip_address_type

  dynamic "dns_options" {
    for_each = var.vpc_endpoint_dns_options.dns_record_ip_type != null || var.vpc_endpoint_dns_options.private_dns_only_for_inbound_resolver_endpoint != null ? [var.vpc_endpoint_dns_options] : []
    content {
      dns_record_ip_type                             = dns_options.value.dns_record_ip_type
      private_dns_only_for_inbound_resolver_endpoint = dns_options.value.private_dns_only_for_inbound_resolver_endpoint
    }
  }

  tags = merge(
    local.tags,
    var.tags,
    {
      "Name" = "zesty-kompass-compute-s3-${var.cluster_name}"
    },
    var.vpc_endpoint_tags,
  )

  timeouts {
    create = try(var.vpc_endpoint_timeouts.create, "10m")
    update = try(var.vpc_endpoint_timeouts.update, "10m")
    delete = try(var.vpc_endpoint_timeouts.delete, "10m")
  }
}

################################################################################
# Security Group
################################################################################

locals {
  create_s3_vpc_endpoint_security_group = var.create && var.create_s3_vpc_endpoint && var.create_s3_vpc_endpoint_security_group
}

resource "aws_security_group" "this" {
  count = local.create_s3_vpc_endpoint_security_group ? 1 : 0

  name        = var.vpc_endpoint_security_group_use_name_prefix ? null : var.vpc_endpoint_security_group_name
  name_prefix = var.vpc_endpoint_security_group_use_name_prefix ? "${var.vpc_endpoint_security_group_name}-" : null
  description = var.vpc_endpoint_security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    local.tags,
    var.tags,
    {
      "Name" = var.vpc_endpoint_security_group_name
    },
    var.vpc_endpoint_security_group_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "this" {
  for_each = { for k, v in var.vpc_endpoint_security_group_rules : k => v if local.create_s3_vpc_endpoint_security_group }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = try(each.value.protocol, "tcp")
  from_port         = try(each.value.from_port, 443)
  to_port           = try(each.value.to_port, 443)
  type              = try(each.value.type, "ingress")

  # Optional
  description              = try(each.value.description, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}

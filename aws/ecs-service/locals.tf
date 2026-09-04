locals {
  account_id  = data.aws_caller_identity.current.account_id
  cluster_arn = data.aws_ecs_cluster.this.arn
  tags = merge(
    {
      Terraform = "true"
    },
    var.tags,
  )

  actual_container_definition = jsonencode(local.container_definition_kinds[var.container_definition_kind])

  service_exists = var.container_definition_kind != "job"

  container_ports = distinct(length(var.target_group_mappings) > 0 ? [
    for mapping in var.target_group_mappings : mapping.container_port
  ] : [var.container_port])

  target_group_port_mappings = length(var.target_group_mappings) > 0 ? var.target_group_mappings : var.target_group_arn != null ? [
    {
      target_group_arn = var.target_group_arn
      container_port   = var.container_port
    }
  ] : []

  # Ephemeral Fargate volumes backing the paths that must stay writable while the
  # root filesystem is read-only. Keyed by volume name so the task definition and
  # the container mount points cannot drift apart.
  # ECS Exec bind-mounts the SSM agent into the container, and that agent must be able
  # to write its state and logs. AWS does not support pairing ECS Exec with a read-only
  # root filesystem at all, so we mount writable volumes over the agent's paths to keep
  # break-glass access working. The agent runs as root regardless of the container user,
  # so the ownership of these mounts does not matter.
  # /managed-agents is where ECS bind-mounts the exec agent binary itself; without a
  # writable mount pre-existing at that path the bind-mount has nowhere to land and
  # container startup fails outright, not just `execute-command`.
  ecs_exec_writable_paths = var.enable_ecs_exec && var.readonly_root_filesystem ? [
    "/var/lib/amazon/ssm",
    "/var/log/amazon/ssm",
    "/managed-agents",
  ] : []

  effective_writable_paths = distinct(concat(var.writable_paths, local.ecs_exec_writable_paths))

  writable_volumes = var.readonly_root_filesystem ? {
    for path in local.effective_writable_paths :
    replace(trimprefix(path, "/"), "/", "-") => path
  } : {}

  mount_points = [
    for name, path in local.writable_volumes : {
      sourceVolume  = name
      containerPath = path
      readOnly      = false
    }
  ]

  # Paths the application process itself writes to. The SSM agent paths are excluded:
  # that agent runs as root regardless of `container_user`, so it does not need the
  # permission fix-up below (and must not have its directories reassigned to the app
  # user).
  app_writable_volumes = var.readonly_root_filesystem ? {
    for path in var.writable_paths :
    replace(trimprefix(path, "/"), "/", "-") => path
  } : {}

  # Fargate mounts ephemeral volumes root-owned, mode 0755, and offers no tmpfs and no
  # way to set the mount owner. A container running as a non-root `container_user`
  # therefore cannot write into its own mounted tmp/log directories and crash-loops on
  # boot. When the caller has declared a non-root user, prepend a throwaway init
  # container that runs as root, chowns those mounts to that user, and exits; the app
  # container then waits for it to succeed before starting.
  needs_volume_permissions_init = var.readonly_root_filesystem && var.container_user != null && length(local.app_writable_volumes) > 0

  volume_permissions_container_name = "${var.service_name}-volume-permissions"

  # Reuses the application image (all our images are Alpine-based, so /bin/sh and
  # chown are present) to avoid pulling and pinning a second image.
  volume_permissions_container = local.needs_volume_permissions_init ? [{
    name       = local.volume_permissions_container_name
    image      = "${var.docker_image}:${var.docker_tag}"
    essential  = false
    user       = "0"
    entryPoint = ["/bin/sh", "-c"]
    command    = ["chown -R ${var.container_user} ${join(" ", values(local.app_writable_volumes))}"]

    mountPoints = [
      for name, path in local.app_writable_volumes : {
        sourceVolume  = name
        containerPath = path
        readOnly      = false
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
        awslogs-group         = data.aws_cloudwatch_log_group.this.name
      }
    }
  }] : []

  app_container_depends_on = local.needs_volume_permissions_init ? {
    dependsOn = [{
      containerName = local.volume_permissions_container_name
      condition     = "SUCCESS"
    }]
  } : {}

  container_definition_kinds = {
    "web" = concat(local.volume_permissions_container, local.container_definition)
    "job" = concat(local.volume_permissions_container, local.job_container_definition)
  }

  container_definition = [merge(local.app_container_depends_on, {
    name        = var.service_name
    image       = "${var.docker_image}:${var.docker_tag}"
    essential   = true
    environment = var.service_environment_config
    secrets     = var.service_secrets_config
    entryPoint  = var.container_entrypoint
    command     = var.container_command
    user        = var.container_user

    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = local.mount_points

    portMappings = [
      for port in local.container_ports : {
        protocol      = "tcp"
        containerPort = port
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
        awslogs-group         = data.aws_cloudwatch_log_group.this.name
      }
    }
  })]

  job_container_definition = [merge(local.app_container_depends_on, {
    name        = var.service_name
    image       = "${var.docker_image}:${var.docker_tag}"
    essential   = true
    command     = var.container_command
    environment = var.service_environment_config
    secrets     = var.service_secrets_config
    user        = var.container_user

    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = local.mount_points

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
        awslogs-group         = data.aws_cloudwatch_log_group.this.name
      }
    }
  })]

  autoscaling_metrics = var.has_autoscaler ? var.autoscaling_metrics : {}


  ecs_capacity_loss_topic_arns = coalesce(var.ecs_capacity_loss_topic_arns, var.sns_topic_arns)

}

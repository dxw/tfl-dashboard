locals {
  app_name = "tfl"

  app_github_owner = "dxw"
  app_github_repo  = "tfl-dashboard"
  app_service_name = "${local.app_name}-${var.environment}"

  app_container_entrypoint = ["./docker-entrypoint.sh"]
  app_container_command    = ["bundle", "exec", "puma", "-p", "5000"]
}

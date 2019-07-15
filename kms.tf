resource "aws_kms_key" "app_ssm" {
  description             = "${local.app_name} SSM key ${terraform.workspace}"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "app_ssm" {
  name          = "alias/${local.app_name}-ssm-${terraform.workspace}"
  target_key_id = "${aws_kms_key.app_ssm.key_id}"
}

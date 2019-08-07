## ECR repository
resource "aws_ecr_repository" "app" {
  name = "${terraform.workspace}-${local.app_name}"
}

## CodePipeline

### Source Bucket
resource "aws_s3_bucket" "app_source" {
  bucket        = "${local.app_name}-${terraform.workspace}-source"
  acl           = "private"
  force_destroy = true
}

### CodePipeline Role/Policy
data "template_file" "app_codepipeline_policy" {
  template = "${file("./policies/codepipeline_policy.json.tpl")}"

  vars = {
    aws_s3_bucket_arn = "${aws_s3_bucket.app_source.arn}"
  }
}

resource "aws_iam_role" "app_codepipeline_role" {
  name               = "${local.app_name}-${terraform.workspace}-codepipeline-role"
  assume_role_policy = "${file("./policies/codepipeline_role.json.tpl")}"
}

resource "aws_iam_role_policy" "app_codepipeline_policy" {
  name   = "${local.app_name}-${terraform.workspace}-codepipeline-policy"
  role   = "${aws_iam_role.app_codepipeline_role.id}"
  policy = "${data.template_file.app_codepipeline_policy.rendered}"
}

### CodeBuild Role/Policy
data "template_file" "app_codebuild_policy" {
  template = "${file("./policies/codebuild_policy.json.tpl")}"

  vars = {
    aws_s3_bucket_arn = "${aws_s3_bucket.app_source.arn}"
  }
}

resource "aws_iam_role" "app_codebuild_role" {
  name               = "${local.app_name}-${terraform.workspace}-codebuild-role"
  assume_role_policy = "${file("./policies/codebuild_role.json.tpl")}"
}

resource "aws_iam_role_policy" "app_codebuild_policy" {
  name   = "${local.app_name}-${terraform.workspace}-codebuild-policy"
  role   = "${aws_iam_role.app_codebuild_role.id}"
  policy = "${data.template_file.app_codebuild_policy.rendered}"
}

### CodeBuild Project
resource "aws_codebuild_project" "app_build" {
  name          = "${local.app_name}-${terraform.workspace}-codebuild"
  build_timeout = "10"
  service_role  = "${aws_iam_role.app_codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "RAILS_ENV"
      value = "${var.environment}"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${local.account_id}"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${terraform.workspace}-${local.app_name}"
    }

    environment_variable {
      name  = "APP_NAME"
      value = "${local.app_name}"
    }

    environment_variable {
      name  = "TERRAFORM_WORKSPACE"
      value = "${terraform.workspace}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

### CodePipeline
resource "aws_codepipeline" "app_pipeline" {
  name     = "${local.app_name}-${terraform.workspace}-pipeline"
  role_arn = "${aws_iam_role.app_codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.app_source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner      = "${local.app_github_owner}"
        Repo       = "${local.app_github_repo}"
        Branch     = "${var.track_revision}"
        OAuthToken = "${var.app_github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration = {
        ProjectName = "${local.app_name}-${terraform.workspace}-codebuild"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${local.app_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

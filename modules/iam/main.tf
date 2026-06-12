data "tls_certificate" "github"{
    url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# ==============================================================================
# 1. TRUST POLICIES (Who is allowed to assume these roles?)
# ==============================================================================

# Trust policy for ECS (Tasks & Infrastructure Execution)
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Registers the GitHub OIDC Identity Provider in AWS
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Secure Trust policy for GitHub Actions (Restricted strictly to YOUR repo)
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Limits access strictly to your repo organization space
      values   = ["repo:${var.github_username}/${var.github_repo_name}:*"]
    }
  }
}

# ==============================================================================
# 2. DEFINING THE THREE ROLES
# ==============================================================================

# ROLE 1: GitHub CI/CD Deploy Role
resource "aws_iam_role" "github_ci_deploy" {
  name               = "${var.project_name}-${var.environment}-github-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# ROLE 2: ECS Task Execution Role (Infrastructure agent management)
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# ROLE 3: ECS Task Role (Your Spring Boot runtime container permissions)
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# ==============================================================================
# 3. ATTACHING PERMISSIONS POLICIES
# ==============================================================================

# Attach standard ECS infra policy to Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline Custom Policy allowing GitHub to push Docker images and cycle ECS tasks
resource "aws_iam_policy" "github_deploy_permissions" {
  name        = "${var.project_name}-${var.environment}-github-deploy-policy"
  description = "Allows GitHub Actions pipelines to write to ECR and update ECS clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_deploy_attachment" {
  role       = aws_iam_role.github_ci_deploy.name
  policy_arn = aws_iam_policy.github_deploy_permissions.arn
}
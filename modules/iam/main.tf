data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# ==============================================================================
# 1. TRUST POLICIES
# ==============================================================================

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

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
      values   = ["repo:${var.github_username}/${var.github_repo_name}:*"]
    }
  }
}

# ==============================================================================
# 2. ROLES
# ==============================================================================

resource "aws_iam_role" "github_ci_deploy" {
  name               = "${var.project_name}-${var.environment}-github-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# Execution role - used by AWS BEFORE your container starts
# Responsibilities: pull image from ECR, inject SSM secrets into the container
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# Task role - used by your RUNNING Spring Boot container
# Responsibilities: any AWS call your app code makes at runtime (S3, SQS, etc.)
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# ==============================================================================
# 3. EXECUTION ROLE PERMISSIONS
# Needed so ECS can pull your image and inject secrets before the app starts
# ==============================================================================

# Base ECS execution policy (ECR image pull + CloudWatch logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# SSM read access for the execution role
# Without this, ECS cannot inject your DB password / JWT secrets into the container
resource "aws_iam_role_policy" "execution_ssm_read" {
  name = "${var.project_name}-${var.environment}-execution-ssm-read"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSSMSecrets"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        # Scoped strictly to this project + environment - cannot read other projects' secrets
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      },
      {
        Sid    = "DecryptSSMWithKMS"
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        # Allows decryption of SecureString parameters (encrypted by AWS managed key)
        Resource = "*"
      }
    ]
  })
}

# ==============================================================================
# 4. TASK ROLE PERMISSIONS
# Used by your running Spring Boot container for any AWS calls it makes
# ==============================================================================

resource "aws_iam_role_policy" "task_role_permissions" {
  name = "${var.project_name}-${var.environment}-task-permissions"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # -- SSM: lets your app re-read secrets at runtime if needed ---------------
      {
        Sid    = "SSMReadAtRuntime"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
      },
      {
        Sid      = "KMSDecryptForSSM"
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
      },
      # -- CloudWatch: lets your app write custom metrics or structured logs -----
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}:*"
      }
      # -- S3 (commented out - uncomment when you add the S3 module) -------------
      # {
      #   Sid    = "S3AppStorage"
      #   Effect = "Allow"
      #   Action = [
      #     "s3:GetObject",
      #     "s3:PutObject",
      #     "s3:DeleteObject",
      #     "s3:ListBucket"
      #   ]
      #   Resource = [
      #     "arn:aws:s3:::${var.project_name}-${var.environment}-storage",
      #     "arn:aws:s3:::${var.project_name}-${var.environment}-storage/*"
      #   ]
      # }
    ]
  })
}

# ==============================================================================
# 5. GITHUB ACTIONS PERMISSIONS
# Allows CI/CD to push images to ECR and trigger rolling ECS deploys
# ==============================================================================

resource "aws_iam_policy" "github_deploy_permissions" {
  name        = "${var.project_name}-${var.environment}-github-deploy-policy"
  description = "Allows GitHub Actions to push to ECR and update ECS"

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
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
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
  
  # Note: Modified to point directly to your custom policy resource above safely
  depends_on = [aws_iam_policy.github_deploy_permissions]
}
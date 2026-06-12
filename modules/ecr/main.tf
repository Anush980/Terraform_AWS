resource "aws_ecr_repository" "app" {
    name = "${var.project_name}-${var.environment}-ecr"
    image_tag_mutability = "IMMUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
    tags = {
        Name = "${var.project_name}-${var.environment}"
    }
}

resource "aws_ecr_lifecycle_policy" "app_policy" {
    repository = aws_ecr_repository.app.name

    policy = jsonencode({
        rules =[
            {
  "rulePriority": 1,
  "description": "Automatically wipe out loose untagged images",
  "selection": {
    "tagStatus": "untagged",
    "countType": "sinceImagePushed",
    "countUnit": "days",
    "countNumber": 7
  },
  "action": {
    "type": "expire"
  }
},
{
  "rulePriority": 2,
  "description": "Keep only the last 5 active deployment images",
  "selection": {
    "tagStatus": "any",
    "countType": "imageCountMoreThan",
    "countNumber": 5
  },
  "action": {
    "type": "expire"
  }
}
        ]
    })
}
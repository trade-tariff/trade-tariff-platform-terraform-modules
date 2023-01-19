resource "aws_ecr_repository" "docker" {
  count                = length(var.docker_repositories)
  name                 = element(var.docker_repositories, count.index)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "rule" {
  count      = length(var.docker_repositories)
  repository = element(var.docker_repositories, count.index)

  depends_on = [aws_ecr_repository.docker]

  policy = jsonencode(
    {
      rules = [
        {
          action = {
            type = "expire"
          }
          description  = "Keep last 30 images"
          rulePriority = 1
          selection = {
            countNumber = 30
            countType   = "imageCountMoreThan"
            tagPrefixList = [
              "dev",
            ]
            tagStatus = "tagged"
          }
        },
      ]
    }
  )
}

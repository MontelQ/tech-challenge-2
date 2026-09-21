resource "aws_ecr_repository" "app" {
  name                 = "tech-challenge-2"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

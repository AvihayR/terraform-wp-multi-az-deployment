resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = var.repo_name
  }
}

output "url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}

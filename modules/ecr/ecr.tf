resource "aws_ecr_repository" "ecr_repository" {
    name = var.repo_name
    image_tag_mutability = "IMMUTABLE"

    tags = {
        Name = var.repo_name
    }
}


resource "aws_ecr_repository" "this" {
  for_each = toset(var.image_name)
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "skopeo_copy" "this" {
    depends_on = [
      aws_ecr_repository.this
    ]
    for_each = toset(var.image_name)
    source_image        = "docker://${var.source_registry}/${each.key}"  
    destination_image   = "docker://${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com/${each.key}"
}
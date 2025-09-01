provider "aws" {
  # IAM is global; pick a canonical region (default via var.region).
  region = "ap-southeast-1"
  profile = var.aws_profile

  default_tags {
    tags = var.default_tags
  }
}

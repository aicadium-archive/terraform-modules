provider "aws" {
  region = var.aws_region
}

provider "google" {
  version = "~> 2.3"

  region  = var.gcp_region
  project = var.gcp_project_id
}

provider "google-beta" {
  version = "~> 2.3"

  region  = var.gcp_region
  project = var.gcp_project_id
}

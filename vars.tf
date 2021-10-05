locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "k8s"
  }
}
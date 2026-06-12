terraform {
  backend "s3" {
    bucket       = "devops-challenge2-terraform-state-381491979307"
    key          = "tech-challenge1-5/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}
terraform {
  backend "s3" {
    bucket       = "tc2-tfstate-394228349360-us-east-1"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

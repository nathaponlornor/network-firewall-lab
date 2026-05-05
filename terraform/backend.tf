terraform {
  backend "s3" {
    bucket                      = "network-firewall-lab-176501510816-tfstate"
    key                         = "lab/terraform.tfstate"
    region                      = "ap-southeast-7"
    encrypt                     = true
    dynamodb_table              = "terraform-state-lock"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

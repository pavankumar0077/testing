terraform {
  # Using local backend for testing purposes
  backend "local" {
    path = "terraform.tfstate"
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws.global,
        aws.fm
      ]
    }
  }
}
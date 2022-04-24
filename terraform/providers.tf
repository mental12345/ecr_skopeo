terraform {
  required_providers {
    skopeo = {
      source            = "abergmeier/skopeo"
      version           = "0.0.4"
    }
    aws = {
        source          = "hashicorp/aws"
        version         = "4.11.0" 
    }
  }
}



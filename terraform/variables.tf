variable "image_name" {
  description   = "List of images to copy to ecr"
  type          = list(string)
  default       = ["ubuntu",
                    "alpine", 
                    "fedora"]

}

variable "source_registry" {
    default     = "docker.io"
}

variable "aws_account" {
    default     = ""
}

variable "aws_region" {
    default     = "us-east-1"
}
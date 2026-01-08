variable "bucket_name" {
  type = string
  # TODO: delete this
  default = "janice-zhong"
}

variable "domain_suffix" {
  type = string
  # TODO: delete this
  default = "com"
}

variable "tags" {
  type = object({
    Project = string
  })
  default = {
    Project = "cloud-resume-challenge"
  }
}

locals {
  full_domain = format("%s.%s", var.bucket_name, var.domain_suffix)
}
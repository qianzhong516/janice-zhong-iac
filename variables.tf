variable "bucket_name" {
  type = string
}

variable "domain_suffix" {
  type = string
}

variable "web_acl_id" {
  type = string
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
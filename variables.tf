variable "env" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "web_acl_id" {
  type = string
}

variable "route53_domain" {
  type = string
}

variable "tags" {
  type = object({
    Project     = string
    Environment = string
  })
}

# settings based on env
variable "settings" {
  type = map(object({
    domain_name     = string
    api_domain_name = string
  }))
}

locals {
  domain_name     = var.settings[var.env].domain_name
  api_domain_name = var.settings[var.env].api_domain_name
}
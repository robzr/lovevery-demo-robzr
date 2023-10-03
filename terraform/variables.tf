variable "app_chart" {
  type = object({
    name        = string
    path        = string
    values_file = string
    version     = string
  })
}

variable "ingress" {
  type = object({
    enabled = bool
    version = optional(string)
  })
}

variable "namespace" {
  type = string
}

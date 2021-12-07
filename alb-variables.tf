# AWS Application and Network Load Balancer (ALB & NLB) Variables
variable "rule4_action_hosts" {
  description = "Action Host"
  type = string
  default = "domain.com"
}

variable "rule4_action_path" {
  description = "Action Path"
  type = string
  default = "/sub-path/"
}

variable "rule4_action_protocol" {
  description = "Action Protocol"
  type = string
  default = "HTTPS"
}

variable "rule4_conditions_host_headers" {
  description = "A list of host headers"
  type        = list(string)
  default     = ["host-header.domain.com"]
}
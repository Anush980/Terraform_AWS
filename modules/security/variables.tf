variable "project_name" { type = string }
variable "environment"  { type = string }

variable "enable_dual_tokens" {
    type = bool
    description = "if true geenrates two tokens access and refrsh token else just jwt toekn "
    default = false
}

variable "third_party_secrets" {
  type = map(object({
    enabled     = bool
    value       = string
    description = string
  }))
  description = "A centralized map container for dynamic third-party credentials"
  default     = {}
}
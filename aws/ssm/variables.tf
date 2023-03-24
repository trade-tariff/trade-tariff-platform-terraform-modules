variable "tags" {
  type        = object({})
  description = "Map of tags to pass on to the module resources."
  default     = {}
}

variable "parameters" {
  description = "List of SSM parameter objects to create."
  type = list(object(
    {
      name  = string
      value = any
      tier  = optional(string)
    }
  ))
}

variable "create_kms_key" {
  description = "Whether to create a KMS key to encrypt the SSM parameters at rest."
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "ID of the KMS key to use to encrypt the parameters at rest. If supplying a key external to the module, this takes precedence over the key created using `create_kms_key`."
  type        = string
  default     = null
}

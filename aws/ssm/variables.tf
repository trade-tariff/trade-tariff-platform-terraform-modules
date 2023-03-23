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

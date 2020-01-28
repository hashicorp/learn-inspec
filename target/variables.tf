variable "example" {
  description = "Example variable"
  default     = "example"
}

variable "example2" {
  description = "Example variable 2"
  default     = ""
}

variable "example_list" {
  description = "An example variable that is a list."
  type        = "list"
  default     = []
}

variable "example_map" {
  description = "An example variable that is a map."
  type        = "map"
  default     = {}
}

variable "key_name" {
  type = string
  default = "key-name"
}

variable "key_public_source" {
    type = string
    default = "~/.ssh/id_rsa.pub"
}
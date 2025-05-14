variable "bastion_key_pairs" {
  type = list(object({
    name = string
    key  = string
  }))
}

resource "aws_key_pair" "bastion_key_pairs" {
  count      = length(var.bastion_key_pairs)
  key_name   = var.bastion_key_pairs[count.index]["name"]
  public_key = var.bastion_key_pairs[count.index]["key"]
}

output "bastion_first_key_name" {
  value = aws_key_pair.bastion_key_pairs[0].key_name
}

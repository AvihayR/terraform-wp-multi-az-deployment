resource "aws_key_pair" "bastion_key_pairs" {
  count      = length(var.bastion_key_pairs)
  key_name   = var.bastion_key_pairs[count.index]["name"]
  public_key = var.bastion_key_pairs[count.index]["key"]
}

output "pairs" {
  value = aws_key_pair.bastion_key_pairs
}

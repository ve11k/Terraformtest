resource "aws_key_pair" "key" {
    key_name = var.key_name
    public_key = var.key_public_source
}

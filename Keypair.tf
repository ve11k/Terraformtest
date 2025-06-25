/*resource "aws_key_pair" "test-key" {
  key_name = "test-key"
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxe3SJd4WOG0dsF093dshJB/erev20J+XKi78anE50u snurn@DESKTOP-TSSSPNE"
  public_key = file("${path.module}/keys/testkey.pub")
}*/
/*resource "aws_key_pair" "private-key" {
  key_name = "private-key"
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFy73ITnVpLziD8ADZdkTYuzF/46PdYTtgbnbfMmMQle snurn@DESKTOP-TSSSPNE"
  public_key = file("${path.module}/keys/privatekey.pub")
}*/
module "module_key_main" {
  source = "./module_key"
  key_name = "test_key"
  key_public_source = var.test_key_pem
}
module "module_key_second" {
  source = "./module_key"
  key_name = "private_key"
  key_public_source = var.private_key_pem
}

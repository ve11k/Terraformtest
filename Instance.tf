resource "aws_instance" "web_test" {
  ami                         = data.aws_ami.amiID.id
  instance_type               = "t2.micro"
  key_name                    = "test-key"
  subnet_id                   = aws_subnet.test_pub_1.id
  vpc_security_group_ids      = [aws_security_group.test_sg.id]
  availability_zone           = var.region_zone
  associate_public_ip_address = true

  tags = {
    Name = "Test_Main_Instance"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.web_test.public_ip}"

  }
  provisioner "file" {
    source      = "deploy_cloudwatch.sh"
    destination = "/tmp/deploy_cloudwatch.sh"
  }
  provisioner "remote-exec" {

    inline = [
      "chmod +x /tmp/deploy_cloudwatch.sh",
      "sudo /tmp/deploy_cloudwatch.sh"
    ]
  }

}

resource "aws_instance" "web_test_private" {
  ami                         = data.aws_ami.amiID.id
  instance_type               = "t2.micro"
  key_name                    = "private-key"
  subnet_id                   = aws_subnet.test_priv_1.id
  vpc_security_group_ids      = [aws_security_group.test_private_sg.id]
  availability_zone           = var.region_zone
  associate_public_ip_address = false

  provisioner "file" {
    source      = "script_wb.sh"
    destination = "/tmp/script_wb.sh"
  }
  provisioner "remote-exec" {

    inline = [
      "chmod +x /tmp/script_wb.sh",
      "sudo /tmp/script_wb.sh"
    ]
  }
  tags = {
    Name = "Test_Second_Instance"
  }
  connection {
  type                = "ssh"
  user                = "ubuntu"                       
  private_key         = file("/privatekey")   
  host                = self.private_ip               

  bastion_host        = aws_instance.web_test.public_ip
  bastion_user        = "ubuntu"                       
  bastion_private_key = file("/testkey")       
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.web_test_private.private_ip}"

  }
}

/*output "Ip_addrpublicvm" {
  description = "IP addr of public vm ip"
  value       = aws_instance.web_test.public_ip

}
output "Ip_addrprivatevm" {
  description = "IP addr of private vm ip"
  value       = aws_instance.web_test_private.private_ip

}*/

resource "aws_instance" "web_test" {
  ami                         = data.aws_ami.amiID.id
  instance_type               = "t2.micro"
  key_name                    = "test-key"
  subnet_id                   = aws_subnet.test_pub_1.id
  vpc_security_group_ids      = [aws_security_group.test_sg.id]
  availability_zone           = variable.region_zone
  associate_public_ip_address = true

  tags = {
    Name = "Test_Main_Instance"
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.web_test.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [ 
      "DD_API_KEY=${variable.datadog_api_key} bash -c \"$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\""
      
      ]
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("keys/testkey")
    host        = self.public_ip
    }

}

/*resource "aws_instance" "web_test_private" {
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
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("keys/privatekey")
    host        = self.private_ip

    bastion_host        = aws_instance.web_test.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("keys/testkey")
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.web_test_private.private_ip}"

  }
}*/

/*output "Ip_addrpublicvm" {
  description = "IP addr of public vm ip"
  value       = aws_instance.web_test.public_ip

}
output "Ip_addrprivatevm" {
  description = "IP addr of private vm ip"
  value       = aws_instance.web_test_private.private_ip

}*/

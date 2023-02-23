resource "aws_instance" "name" {
  ami = "ami-0ffac3e16de16665e"
  instance_type = "t2.micro"
}
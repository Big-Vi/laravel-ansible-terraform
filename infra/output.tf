# Webserver IP Address
output "webserver_ip" {
  value = aws_instance.server.public_ip
}

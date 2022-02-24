output "WebODM portal" {
  value = aws_instance.webodm.public_ip
}
output "WebODM_internal_ip" {
  value = aws_instance.webodm.private_ip
}
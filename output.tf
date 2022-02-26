output "WebODM_public_ip" {
  value = aws_instance.webodm.*.public_ip
}
output "WebODM_internal_ip" {
  value = aws_instance.webodm.*.private_ip
}
output "nodeODM_internal_ip" {
  value = aws_instance.nodeodm.*.private_ip
}

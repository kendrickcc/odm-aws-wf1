output "WebODM_public_ip" {
  value = aws_instance.webodm.*.public_ip
}
output "ClusterODM_internal_ip" {
  value = aws_instance.webodm.*.private_ip
}
output "NodeODM_internal_ip" {
  value = aws_instance.nodeodm.*.private_ip
}

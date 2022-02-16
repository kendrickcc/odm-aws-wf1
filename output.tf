output "WebODM_provisioned" {
  value = "http://${aws_instance.webodm.public_ip}:8000"
}
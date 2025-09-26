output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.docker_host.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance."
  value       = aws_instance.docker_host.public_dns
}

output "web_access_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.docker_host.public_dns}"
}

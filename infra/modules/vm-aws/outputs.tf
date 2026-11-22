output "public_ip" {
  description = "IP publique de la VM"
  value       = aws_instance.this.public_ip
}

output "ssh_user" {
  description = "Utilisateur SSH"
  value       = var.ssh_user
}

output "instance_id" {
  description = "Identifiant AWS de l'instance (informatif)"
  value       = aws_instance.this.id
}

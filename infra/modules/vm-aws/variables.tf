# Interface commune des modules "vm-*" (voir docs/PROVIDER_CONTRACT.md)
# Entrees : name, size, ssh_public_key, open_ports (+ user_data, ssh_user)
# Sorties : public_ip, ssh_user
# La region AWS se choisit au niveau du provider, dans infra/envs/aws.

variable "name" {
  description = "Nom de la VM et prefixe des ressources"
  type        = string
}

variable "size" {
  description = "Type d'instance (famille t3 = x86, compatible avec l'image amd64)"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "Contenu de la cle publique SSH a injecter"
  type        = string
}

variable "open_ports" {
  description = "Ports TCP entrants ouverts"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorise pour le port 22 (ex. 1.2.3.4/32). 0.0.0.0/0 = ouvert, cle SSH obligatoire"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_user" {
  description = "Utilisateur SSH cree par cloud-init (identique chez tous les fournisseurs)"
  type        = string
  default     = "deploy"
}

variable "user_data" {
  description = "Contenu cloud-init"
  type        = string
  default     = ""
}

variable "disk_size_gb" {
  description = "Taille du disque racine (Go)"
  type        = number
  default     = 20
}
